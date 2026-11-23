const router = require('express').Router();
const { query, giaoDich } = require('../db');
const { xacThuc } = require('../middleware/auth');
const { HttpError, boc, layId, batBuocSoNguyen, batBuocThoiGian } = require('../utils/http');

router.use(xacThuc);

const TRANG_THAI = ['da_dat', 'da_huy', 'het_han', 'hoan_thanh'];

// GET /api/dat-cho?trang_thai=da_dat - khách thấy của mình, nhân viên/admin thấy tất cả
router.get('/', boc(async (req, res) => {
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  const params = [];
  const dieuKien = [];
  if (vaiTro === 'khach_hang') {
    params.push(id);
    dieuKien.push(`dc.nguoi_dung_id = $${params.length}`);
  }
  if (req.query.trang_thai) {
    if (!TRANG_THAI.includes(req.query.trang_thai)) throw new HttpError(400, `trang_thai chỉ nhận: ${TRANG_THAI.join(', ')}`);
    params.push(req.query.trang_thai);
    dieuKien.push(`dc.trang_thai = $${params.length}`);
  }
  const where = dieuKien.length ? `WHERE ${dieuKien.join(' AND ')}` : '';
  const { rows } = await query(
    `SELECT dc.id, dc.bat_dau, dc.het_han, dc.trang_thai, dc.tao_luc,
            x.bien_so, cd.ma_cho, b.ten AS ten_bai, nd.ho_ten AS khach
       FROM dat_cho dc
       JOIN xe x ON x.id = dc.xe_id
       JOIN cho_do cd ON cd.id = dc.cho_do_id
       JOIN bai_xe b ON b.id = cd.bai_xe_id
       JOIN nguoi_dung nd ON nd.id = dc.nguoi_dung_id
       ${where}
      ORDER BY dc.id DESC`,
    params,
  );
  res.json(rows);
}));

// POST /api/dat-cho - đặt chỗ (giao dịch: khóa chỗ đỗ để 2 người không đặt trùng)
router.post('/', boc(async (req, res) => {
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  const xeId = batBuocSoNguyen(req.body.xe_id, 'xe_id');
  const choId = batBuocSoNguyen(req.body.cho_do_id, 'cho_do_id');
  const batDau = batBuocThoiGian(req.body.bat_dau, 'bat_dau');
  const hetHan = batBuocThoiGian(req.body.het_han, 'het_han');
  if (hetHan <= batDau) throw new HttpError(400, 'het_han phải sau bat_dau');

  const datCho = await giaoDich(async (client) => {
    const xe = (await client.query('SELECT id, nguoi_dung_id, loai_xe FROM xe WHERE id = $1', [xeId])).rows[0];
    if (!xe) throw new HttpError(404, 'Không tìm thấy xe');
    if (vaiTro === 'khach_hang' && xe.nguoi_dung_id !== id) throw new HttpError(403, 'Đây không phải xe của bạn');

    const cho = (await client.query(
      'SELECT id, loai_xe, trang_thai FROM cho_do WHERE id = $1 FOR UPDATE', [choId],
    )).rows[0];
    if (!cho) throw new HttpError(404, 'Không tìm thấy chỗ đỗ');
    if (cho.loai_xe !== xe.loai_xe) throw new HttpError(400, 'Chỗ đỗ không phù hợp loại xe');
    if (cho.trang_thai !== 'trong') throw new HttpError(409, 'Chỗ đỗ này không còn trống');

    const { rows } = await client.query(
      `INSERT INTO dat_cho (nguoi_dung_id, xe_id, cho_do_id, bat_dau, het_han)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, xe_id, cho_do_id, bat_dau, het_han, trang_thai`,
      [xe.nguoi_dung_id, xeId, choId, batDau, hetHan],
    );
    await client.query("UPDATE cho_do SET trang_thai = 'da_dat' WHERE id = $1", [choId]);
    return rows[0];
  });
  res.status(201).json(datCho);
}));

// PATCH /api/dat-cho/:id/huy - hủy đặt chỗ, trả chỗ về trống
router.patch('/:id/huy', boc(async (req, res) => {
  const datChoId = layId(req);
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  const ketQua = await giaoDich(async (client) => {
    const dc = (await client.query('SELECT * FROM dat_cho WHERE id = $1 FOR UPDATE', [datChoId])).rows[0];
    if (!dc) throw new HttpError(404, 'Không tìm thấy đặt chỗ');
    if (vaiTro === 'khach_hang' && dc.nguoi_dung_id !== id) throw new HttpError(403, 'Đây không phải đặt chỗ của bạn');
    if (dc.trang_thai !== 'da_dat') throw new HttpError(409, 'Đặt chỗ này không thể hủy nữa');

    const { rows } = await client.query(
      "UPDATE dat_cho SET trang_thai = 'da_huy' WHERE id = $1 RETURNING id, trang_thai", [datChoId],
    );
    await client.query("UPDATE cho_do SET trang_thai = 'trong' WHERE id = $1 AND trang_thai = 'da_dat'", [dc.cho_do_id]);
    return rows[0];
  });
  res.json(ketQua);
}));

module.exports = router;
