const router = require('express').Router();
const { query } = require('../db');
const { xacThuc, phanQuyen } = require('../middleware/auth');
const { HttpError, boc, layId, batBuocTrongDanhSach } = require('../utils/http');

router.use(xacThuc, phanQuyen('admin'));

// GET /api/nguoi-dung?vai_tro=khach_hang - danh sách người dùng (admin)
router.get('/', boc(async (req, res) => {
  const params = [];
  let loc = '';
  if (req.query.vai_tro) {
    params.push(req.query.vai_tro);
    loc = `WHERE vt.ten = $${params.length}`;
  }
  const { rows } = await query(
    `SELECT nd.id, nd.ten_dang_nhap, nd.ho_ten, nd.email, nd.so_dien_thoai, vt.ten AS vai_tro, nd.tao_luc
       FROM nguoi_dung nd JOIN vai_tro vt ON vt.id = nd.vai_tro_id
       ${loc}
      ORDER BY nd.id`,
    params,
  );
  res.json(rows);
}));

// PATCH /api/nguoi-dung/:id/vai-tro - đổi vai trò (admin)
router.patch('/:id/vai-tro', boc(async (req, res) => {
  const id = layId(req);
  const vaiTro = batBuocTrongDanhSach(req.body.vai_tro, ['admin', 'nhan_vien', 'khach_hang'], 'vai_tro');
  if (id === req.nguoiDung.id) throw new HttpError(400, 'Không thể tự đổi vai trò của chính mình');
  const { rows } = await query(
    `UPDATE nguoi_dung SET vai_tro_id = (SELECT id FROM vai_tro WHERE ten = $2)
      WHERE id = $1
  RETURNING id, ten_dang_nhap, ho_ten, $2::text AS vai_tro`,
    [id, vaiTro],
  );
  if (!rows[0]) throw new HttpError(404, 'Không tìm thấy người dùng');
  res.json(rows[0]);
}));

// DELETE /api/nguoi-dung/:id - xóa người dùng (admin)
router.delete('/:id', boc(async (req, res) => {
  const id = layId(req);
  if (id === req.nguoiDung.id) throw new HttpError(400, 'Không thể tự xóa chính mình');
  const { rowCount } = await query('DELETE FROM nguoi_dung WHERE id = $1', [id]);
  if (!rowCount) throw new HttpError(404, 'Không tìm thấy người dùng');
  res.status(204).end();
}));

module.exports = router;
