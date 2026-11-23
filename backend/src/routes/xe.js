const router = require('express').Router();
const { query } = require('../db');
const { xacThuc } = require('../middleware/auth');
const {
  HttpError, boc, layId, LOAI_XE, batBuocChuoi, batBuocTrongDanhSach, batBuocSoNguyen,
} = require('../utils/http');

router.use(xacThuc);

// GET /api/xe - khách thấy xe của mình, nhân viên/admin thấy tất cả
router.get('/', boc(async (req, res) => {
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  const params = [];
  let loc = '';
  if (vaiTro === 'khach_hang') {
    params.push(id);
    loc = 'WHERE x.nguoi_dung_id = $1';
  }
  const { rows } = await query(
    `SELECT x.id, x.bien_so, x.loai_xe, x.hang_xe, x.nguoi_dung_id, nd.ho_ten AS chu_xe
       FROM xe x JOIN nguoi_dung nd ON nd.id = x.nguoi_dung_id
       ${loc}
      ORDER BY x.id`,
    params,
  );
  res.json(rows);
}));

// POST /api/xe - đăng ký xe (khách đăng ký cho mình; nhân viên/admin truyền nguoi_dung_id)
router.post('/', boc(async (req, res) => {
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  const bienSo = batBuocChuoi(req.body.bien_so, 'bien_so', 4, 20).toUpperCase();
  const loaiXe = batBuocTrongDanhSach(req.body.loai_xe, LOAI_XE, 'loai_xe');
  const hangXe = req.body.hang_xe ? batBuocChuoi(req.body.hang_xe, 'hang_xe', 1, 50) : null;
  const chuXe = vaiTro === 'khach_hang' ? id : batBuocSoNguyen(req.body.nguoi_dung_id, 'nguoi_dung_id');

  const { rows } = await query(
    `INSERT INTO xe (nguoi_dung_id, bien_so, loai_xe, hang_xe) VALUES ($1, $2, $3, $4)
     RETURNING id, bien_so, loai_xe, hang_xe, nguoi_dung_id`,
    [chuXe, bienSo, loaiXe, hangXe],
  );
  res.status(201).json(rows[0]);
}));

// DELETE /api/xe/:id - chủ xe hoặc admin xóa
router.delete('/:id', boc(async (req, res) => {
  const xeId = layId(req);
  const { rows } = await query('SELECT nguoi_dung_id FROM xe WHERE id = $1', [xeId]);
  if (!rows[0]) throw new HttpError(404, 'Không tìm thấy xe');
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  if (vaiTro !== 'admin' && rows[0].nguoi_dung_id !== id) {
    throw new HttpError(403, 'Bạn không có quyền xóa xe này');
  }
  await query('DELETE FROM xe WHERE id = $1', [xeId]);
  res.status(204).end();
}));

module.exports = router;
