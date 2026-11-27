const router = require('express').Router();
const { query } = require('../db');
const { xacThuc, phanQuyen } = require('../middleware/auth');
const {
  HttpError, boc, layId, LOAI_XE,
  batBuocChuoi, batBuocSoKhongAm, batBuocTrongDanhSach,
} = require('../utils/http');

router.use(xacThuc);

const TRANG_THAI_BAI = ['hoat_dong', 'dong_cua'];
const TRANG_THAI_CHO = ['trong', 'da_dat', 'dang_dung', 'bao_tri'];

// GET /api/bai-xe - danh sách bãi kèm số chỗ trống
router.get('/', boc(async (req, res) => {
  const { rows } = await query(
    `SELECT b.id, b.ten, b.dia_chi, b.anh_url, b.trang_thai,
            COUNT(c.id)::int                                        AS tong_cho,
            COUNT(c.id) FILTER (WHERE c.trang_thai = 'trong')::int  AS cho_trong
       FROM bai_xe b LEFT JOIN cho_do c ON c.bai_xe_id = b.id
      GROUP BY b.id
      ORDER BY b.id`,
  );
  res.json(rows);
}));

// GET /api/bai-xe/:id - chi tiết bãi + bảng giá
router.get('/:id', boc(async (req, res) => {
  const id = layId(req);
  const { rows } = await query(
    'SELECT id, ten, dia_chi, anh_url, trang_thai FROM bai_xe WHERE id = $1', [id],
  );
  if (!rows[0]) throw new HttpError(404, 'Không tìm thấy bãi xe');
  const gia = await query(
    `SELECT loai_xe, gia_theo_gio, gia_toi_da_ngay, gia_ve_thang
       FROM bang_gia WHERE bai_xe_id = $1 ORDER BY loai_xe`, [id],
  );
  res.json({ ...rows[0], bang_gia: gia.rows });
}));

// GET /api/bai-xe/:id/cho-do?trang_thai=trong&loai_xe=o_to
router.get('/:id/cho-do', boc(async (req, res) => {
  const id = layId(req);
  const params = [id];
  const dieuKien = ['bai_xe_id = $1'];
  if (req.query.trang_thai) {
    params.push(batBuocTrongDanhSach(req.query.trang_thai, TRANG_THAI_CHO, 'trang_thai'));
    dieuKien.push(`trang_thai = $${params.length}`);
  }
  if (req.query.loai_xe) {
    params.push(batBuocTrongDanhSach(req.query.loai_xe, LOAI_XE, 'loai_xe'));
    dieuKien.push(`loai_xe = $${params.length}`);
  }
  const { rows } = await query(
    `SELECT id, bai_xe_id, ma_cho, loai_xe, trang_thai
       FROM cho_do WHERE ${dieuKien.join(' AND ')} ORDER BY ma_cho`,
    params,
  );
  res.json(rows);
}));

// POST /api/bai-xe - thêm bãi (admin)
router.post('/', phanQuyen('admin'), boc(async (req, res) => {
  const ten = batBuocChuoi(req.body.ten, 'ten', 2, 100);
  const diaChi = batBuocChuoi(req.body.dia_chi, 'dia_chi', 5, 200);
  const anhUrl = req.body.anh_url ? batBuocChuoi(req.body.anh_url, 'anh_url', 8, 500) : null;
  const { rows } = await query(
    `INSERT INTO bai_xe (ten, dia_chi, anh_url) VALUES ($1, $2, $3)
     RETURNING id, ten, dia_chi, anh_url, trang_thai`,
    [ten, diaChi, anhUrl],
  );
  res.status(201).json(rows[0]);
}));

// PUT /api/bai-xe/:id - sửa bãi (admin)
router.put('/:id', phanQuyen('admin'), boc(async (req, res) => {
  const id = layId(req);
  const ten = batBuocChuoi(req.body.ten, 'ten', 2, 100);
  const diaChi = batBuocChuoi(req.body.dia_chi, 'dia_chi', 5, 200);
  const anhUrl = req.body.anh_url ? batBuocChuoi(req.body.anh_url, 'anh_url', 8, 500) : null;
  const trangThai = batBuocTrongDanhSach(req.body.trang_thai || 'hoat_dong', TRANG_THAI_BAI, 'trang_thai');
  const { rows } = await query(
    `UPDATE bai_xe SET ten = $2, dia_chi = $3, anh_url = $4, trang_thai = $5
      WHERE id = $1 RETURNING id, ten, dia_chi, anh_url, trang_thai`,
    [id, ten, diaChi, anhUrl, trangThai],
  );
  if (!rows[0]) throw new HttpError(404, 'Không tìm thấy bãi xe');
  res.json(rows[0]);
}));

// DELETE /api/bai-xe/:id - xóa bãi (admin). Còn dữ liệu liên quan thì báo 409.
router.delete('/:id', phanQuyen('admin'), boc(async (req, res) => {
  const id = layId(req);
  const { rowCount } = await query('DELETE FROM bai_xe WHERE id = $1', [id]);
  if (!rowCount) throw new HttpError(404, 'Không tìm thấy bãi xe');
  res.status(204).end();
}));

// POST /api/bai-xe/:id/cho-do - thêm chỗ đỗ (admin)
router.post('/:id/cho-do', phanQuyen('admin'), boc(async (req, res) => {
  const id = layId(req);
  const maCho = batBuocChuoi(req.body.ma_cho, 'ma_cho', 1, 10).toUpperCase();
  const loaiXe = batBuocTrongDanhSach(req.body.loai_xe, LOAI_XE, 'loai_xe');
  const { rows } = await query(
    `INSERT INTO cho_do (bai_xe_id, ma_cho, loai_xe) VALUES ($1, $2, $3)
     RETURNING id, bai_xe_id, ma_cho, loai_xe, trang_thai`,
    [id, maCho, loaiXe],
  );
  res.status(201).json(rows[0]);
}));

// PUT /api/bai-xe/:id/bang-gia - đặt/cập nhật giá cho 1 loại xe (admin)
router.put('/:id/bang-gia', phanQuyen('admin'), boc(async (req, res) => {
  const id = layId(req);
  const loaiXe = batBuocTrongDanhSach(req.body.loai_xe, LOAI_XE, 'loai_xe');
  const giaGio = batBuocSoKhongAm(req.body.gia_theo_gio, 'gia_theo_gio');
  const giaNgay = batBuocSoKhongAm(req.body.gia_toi_da_ngay, 'gia_toi_da_ngay');
  const giaThang = batBuocSoKhongAm(req.body.gia_ve_thang, 'gia_ve_thang');
  const { rows } = await query(
    `INSERT INTO bang_gia (bai_xe_id, loai_xe, gia_theo_gio, gia_toi_da_ngay, gia_ve_thang)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (bai_xe_id, loai_xe) DO UPDATE
       SET gia_theo_gio = EXCLUDED.gia_theo_gio,
           gia_toi_da_ngay = EXCLUDED.gia_toi_da_ngay,
           gia_ve_thang = EXCLUDED.gia_ve_thang
     RETURNING bai_xe_id, loai_xe, gia_theo_gio, gia_toi_da_ngay, gia_ve_thang`,
    [id, loaiXe, giaGio, giaNgay, giaThang],
  );
  res.json(rows[0]);
}));

module.exports = router;
