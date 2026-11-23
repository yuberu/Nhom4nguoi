const router = require('express').Router();
const { query, giaoDich } = require('../db');
const { xacThuc, phanQuyen } = require('../middleware/auth');
const { HttpError, boc, layId, batBuocSoNguyen, batBuocTrongDanhSach } = require('../utils/http');

router.use(xacThuc);

const PHUONG_THUC = ['tien_mat', 'chuyen_khoan', 'vi_dien_tu'];

// GET /api/ve-thang - khách thấy của mình, nhân viên/admin thấy tất cả
router.get('/', boc(async (req, res) => {
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  const params = [];
  let loc = '';
  if (vaiTro === 'khach_hang') {
    params.push(id);
    loc = 'WHERE x.nguoi_dung_id = $1';
  }
  const { rows } = await query(
    `SELECT v.id, v.ngay_bat_dau, v.ngay_het_han, v.gia, v.trang_thai,
            x.bien_so, b.ten AS ten_bai
       FROM ve_thang v
       JOIN xe x ON x.id = v.xe_id
       JOIN bai_xe b ON b.id = v.bai_xe_id
       ${loc}
      ORDER BY v.id DESC`,
    params,
  );
  res.json(rows);
}));

// POST /api/ve-thang - mua vé tháng (giao dịch: tạo vé + ghi thanh toán)
router.post('/', boc(async (req, res) => {
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  const xeId = batBuocSoNguyen(req.body.xe_id, 'xe_id');
  const baiXeId = batBuocSoNguyen(req.body.bai_xe_id, 'bai_xe_id');
  const soThang = req.body.so_thang === undefined ? 1 : batBuocSoNguyen(req.body.so_thang, 'so_thang');
  if (soThang > 12) throw new HttpError(400, 'so_thang tối đa là 12');
  const phuongThuc = batBuocTrongDanhSach(req.body.phuong_thuc || 'chuyen_khoan', PHUONG_THUC, 'phuong_thuc');

  const ve = await giaoDich(async (client) => {
    const xe = (await client.query('SELECT id, nguoi_dung_id, loai_xe FROM xe WHERE id = $1', [xeId])).rows[0];
    if (!xe) throw new HttpError(404, 'Không tìm thấy xe');
    if (vaiTro === 'khach_hang' && xe.nguoi_dung_id !== id) throw new HttpError(403, 'Đây không phải xe của bạn');

    const gia = (await client.query(
      'SELECT gia_ve_thang FROM bang_gia WHERE bai_xe_id = $1 AND loai_xe = $2', [baiXeId, xe.loai_xe],
    )).rows[0];
    if (!gia) throw new HttpError(404, 'Bãi chưa có bảng giá cho loại xe này');

    const dangCo = await client.query(
      `SELECT 1 FROM ve_thang
        WHERE xe_id = $1 AND bai_xe_id = $2 AND trang_thai = 'hieu_luc' AND ngay_het_han >= current_date`,
      [xeId, baiXeId],
    );
    if (dangCo.rowCount) throw new HttpError(409, 'Xe này đang có vé tháng còn hiệu lực ở bãi này');

    const tong = gia.gia_ve_thang * soThang;
    const { rows } = await client.query(
      `INSERT INTO ve_thang (xe_id, bai_xe_id, ngay_bat_dau, ngay_het_han, gia)
       VALUES ($1, $2, current_date, current_date + $3::int, $4)
       RETURNING id, xe_id, bai_xe_id, ngay_bat_dau, ngay_het_han, gia, trang_thai`,
      [xeId, baiXeId, 30 * soThang - 1, tong],
    );
    if (tong > 0) {
      await client.query(
        'INSERT INTO thanh_toan (ve_thang_id, so_tien, phuong_thuc) VALUES ($1, $2, $3)',
        [rows[0].id, tong, phuongThuc],
      );
    }
    return rows[0];
  });
  res.status(201).json(ve);
}));

// PATCH /api/ve-thang/:id/huy - hủy vé (nhân viên/admin)
router.patch('/:id/huy', phanQuyen('admin', 'nhan_vien'), boc(async (req, res) => {
  const id = layId(req);
  const { rows } = await query(
    `UPDATE ve_thang SET trang_thai = 'da_huy'
      WHERE id = $1 AND trang_thai = 'hieu_luc' RETURNING id, trang_thai`,
    [id],
  );
  if (!rows[0]) throw new HttpError(404, 'Không tìm thấy vé đang hiệu lực');
  res.json(rows[0]);
}));

module.exports = router;
