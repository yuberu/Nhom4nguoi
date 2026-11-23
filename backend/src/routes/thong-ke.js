const router = require('express').Router();
const { query } = require('../db');
const { xacThuc, phanQuyen } = require('../middleware/auth');
const { boc } = require('../utils/http');

router.use(xacThuc, phanQuyen('admin'));

// GET /api/thong-ke/tong-quan - các con số cho màn hình tổng quan
router.get('/tong-quan', boc(async (req, res) => {
  const { rows } = await query(
    `SELECT
       (SELECT COUNT(*) FROM bai_xe)::int                                          AS so_bai_xe,
       (SELECT COUNT(*) FROM cho_do)::int                                          AS tong_cho,
       (SELECT COUNT(*) FROM cho_do WHERE trang_thai = 'trong')::int               AS cho_trong,
       (SELECT COUNT(*) FROM luot_gui WHERE trang_thai = 'dang_gui')::int          AS xe_dang_gui,
       (SELECT COUNT(*) FROM nguoi_dung)::int                                      AS so_nguoi_dung,
       COALESCE((SELECT SUM(so_tien) FROM thanh_toan WHERE tao_luc::date = current_date), 0)::float AS doanh_thu_hom_nay`,
  );
  res.json(rows[0]);
}));

// GET /api/thong-ke/doanh-thu?so_ngay=7 - doanh thu theo ngày (vẽ biểu đồ cột/đường)
router.get('/doanh-thu', boc(async (req, res) => {
  const soNgay = Math.min(Math.max(Number(req.query.so_ngay) || 7, 1), 90);
  const { rows } = await query(
    `SELECT to_char(d::date, 'YYYY-MM-DD') AS ngay,
            COALESCE(SUM(t.so_tien), 0)::float AS doanh_thu
       FROM generate_series(current_date - ($1::int - 1), current_date, interval '1 day') d
       LEFT JOIN thanh_toan t ON t.tao_luc::date = d::date
      GROUP BY d
      ORDER BY d`,
    [soNgay],
  );
  res.json(rows);
}));

// GET /api/thong-ke/luot-gui-theo-bai - số lượt gửi mỗi bãi (vẽ biểu đồ tròn)
router.get('/luot-gui-theo-bai', boc(async (req, res) => {
  const { rows } = await query(
    `SELECT b.id AS bai_xe_id, b.ten, COUNT(lg.id)::int AS so_luot
       FROM bai_xe b
       LEFT JOIN cho_do cd ON cd.bai_xe_id = b.id
       LEFT JOIN luot_gui lg ON lg.cho_do_id = cd.id
      GROUP BY b.id
      ORDER BY b.id`,
  );
  res.json(rows);
}));

module.exports = router;
