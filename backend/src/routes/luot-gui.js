const router = require('express').Router();
const { query, giaoDich } = require('../db');
const { xacThuc, phanQuyen } = require('../middleware/auth');
const {
  HttpError, boc, layId, batBuocChuoi, batBuocSoNguyen, batBuocTrongDanhSach,
} = require('../utils/http');
const { tinhTien } = require('../utils/tinh-tien');

router.use(xacThuc);

const PHUONG_THUC = ['tien_mat', 'chuyen_khoan', 'vi_dien_tu'];

const CAU_LENH_DANH_SACH = `
  SELECT lg.id, lg.gio_vao, lg.gio_ra, lg.so_tien, lg.trang_thai,
         x.bien_so, x.loai_xe, cd.ma_cho, b.id AS bai_xe_id, b.ten AS ten_bai
    FROM luot_gui lg
    JOIN xe x ON x.id = lg.xe_id
    JOIN cho_do cd ON cd.id = lg.cho_do_id
    JOIN bai_xe b ON b.id = cd.bai_xe_id`;

// GET /api/luot-gui?trang_thai=dang_gui&bai_xe_id=1&limit=50&offset=0
router.get('/', boc(async (req, res) => {
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  const params = [];
  const dieuKien = [];
  if (vaiTro === 'khach_hang') {
    params.push(id);
    dieuKien.push(`x.nguoi_dung_id = $${params.length}`);
  }
  if (req.query.trang_thai) {
    params.push(batBuocTrongDanhSach(req.query.trang_thai, ['dang_gui', 'da_ra'], 'trang_thai'));
    dieuKien.push(`lg.trang_thai = $${params.length}`);
  }
  if (req.query.bai_xe_id) {
    params.push(batBuocSoNguyen(req.query.bai_xe_id, 'bai_xe_id'));
    dieuKien.push(`b.id = $${params.length}`);
  }
  const limit = Math.min(Number(req.query.limit) || 50, 100);
  const offset = Math.max(Number(req.query.offset) || 0, 0);
  params.push(limit, offset);
  const where = dieuKien.length ? `WHERE ${dieuKien.join(' AND ')}` : '';
  const { rows } = await query(
    `${CAU_LENH_DANH_SACH} ${where} ORDER BY lg.id DESC LIMIT $${params.length - 1} OFFSET $${params.length}`,
    params,
  );
  res.json(rows);
}));

// GET /api/luot-gui/:id
router.get('/:id', boc(async (req, res) => {
  const luotId = layId(req);
  const { rows } = await query(
    `${CAU_LENH_DANH_SACH.replace('SELECT lg.id,', 'SELECT x.nguoi_dung_id AS chu_xe_id, lg.id,')} WHERE lg.id = $1`,
    [luotId],
  );
  if (!rows[0]) throw new HttpError(404, 'Không tìm thấy lượt gửi');
  const { id, vai_tro: vaiTro } = req.nguoiDung;
  if (vaiTro === 'khach_hang' && rows[0].chu_xe_id !== id) throw new HttpError(403, 'Đây không phải lượt gửi của bạn');
  res.json(rows[0]);
}));

// POST /api/luot-gui/vao - nhân viên cho xe vào bãi (giao dịch)
// Gửi bien_so + (cho_do_id  HOẶC  bai_xe_id để hệ thống tự chọn chỗ trống). dat_cho_id nếu xe có đặt trước.
router.post('/vao', phanQuyen('admin', 'nhan_vien'), boc(async (req, res) => {
  const bienSo = batBuocChuoi(req.body.bien_so, 'bien_so', 4, 20).toUpperCase();
  const { cho_do_id: choDoId, bai_xe_id: baiXeId, dat_cho_id: datChoId } = req.body;
  if (!choDoId && !baiXeId) throw new HttpError(400, 'Cần cho_do_id hoặc bai_xe_id');

  const luot = await giaoDich(async (client) => {
    const xe = (await client.query('SELECT id, loai_xe FROM xe WHERE bien_so = $1', [bienSo])).rows[0];
    if (!xe) throw new HttpError(404, 'Xe chưa đăng ký trong hệ thống');

    let cho;
    if (choDoId) {
      cho = (await client.query(
        'SELECT id, loai_xe, trang_thai FROM cho_do WHERE id = $1 FOR UPDATE', [batBuocSoNguyen(choDoId, 'cho_do_id')],
      )).rows[0];
      if (!cho) throw new HttpError(404, 'Không tìm thấy chỗ đỗ');
    } else {
      cho = (await client.query(
        `SELECT id, loai_xe, trang_thai FROM cho_do
          WHERE bai_xe_id = $1 AND loai_xe = $2 AND trang_thai = 'trong'
          ORDER BY id LIMIT 1 FOR UPDATE SKIP LOCKED`,
        [batBuocSoNguyen(baiXeId, 'bai_xe_id'), xe.loai_xe],
      )).rows[0];
      if (!cho) throw new HttpError(409, 'Bãi không còn chỗ trống cho loại xe này');
    }
    if (cho.loai_xe !== xe.loai_xe) throw new HttpError(400, 'Chỗ đỗ không phù hợp loại xe');

    let datCho = null;
    if (datChoId) {
      datCho = (await client.query(
        `SELECT id FROM dat_cho
          WHERE id = $1 AND xe_id = $2 AND cho_do_id = $3 AND trang_thai = 'da_dat' FOR UPDATE`,
        [batBuocSoNguyen(datChoId, 'dat_cho_id'), xe.id, cho.id],
      )).rows[0];
      if (!datCho) throw new HttpError(409, 'Đặt chỗ không hợp lệ cho xe và chỗ đỗ này');
      if (cho.trang_thai !== 'da_dat') throw new HttpError(409, 'Chỗ đỗ không ở trạng thái đã đặt');
    } else if (cho.trang_thai !== 'trong') {
      throw new HttpError(409, 'Chỗ đỗ này không còn trống');
    }

    const { rows } = await client.query(
      `INSERT INTO luot_gui (xe_id, cho_do_id, nhan_vien_id, dat_cho_id)
       VALUES ($1, $2, $3, $4)
       RETURNING id, xe_id, cho_do_id, gio_vao, trang_thai`,
      [xe.id, cho.id, req.nguoiDung.id, datCho ? datCho.id : null],
    );
    await client.query("UPDATE cho_do SET trang_thai = 'dang_dung' WHERE id = $1", [cho.id]);
    if (datCho) await client.query("UPDATE dat_cho SET trang_thai = 'hoan_thanh' WHERE id = $1", [datCho.id]);
    return rows[0];
  });
  res.status(201).json(luot);
}));

// POST /api/luot-gui/:id/ra - cho xe ra, tính tiền, thu tiền, trả chỗ (NGHIỆP VỤ GIAO DỊCH CHÍNH)
// Một giao dịch gồm: chốt giờ ra + tính tiền + ghi thanh toán + đổi chỗ đỗ về trống.
router.post('/:id/ra', phanQuyen('admin', 'nhan_vien'), boc(async (req, res) => {
  const luotId = layId(req);
  const phuongThuc = batBuocTrongDanhSach(req.body.phuong_thuc || 'tien_mat', PHUONG_THUC, 'phuong_thuc');

  const ketQua = await giaoDich(async (client) => {
    const lg = (await client.query(
      `SELECT lg.id, lg.xe_id, lg.cho_do_id, lg.gio_vao, lg.trang_thai,
              cd.bai_xe_id, x.loai_xe
         FROM luot_gui lg
         JOIN cho_do cd ON cd.id = lg.cho_do_id
         JOIN xe x ON x.id = lg.xe_id
        WHERE lg.id = $1
          FOR UPDATE OF lg`,
      [luotId],
    )).rows[0];
    if (!lg) throw new HttpError(404, 'Không tìm thấy lượt gửi');
    if (lg.trang_thai !== 'dang_gui') throw new HttpError(409, 'Xe này đã ra khỏi bãi rồi');

    const gioRa = (await client.query('SELECT now() AS bay_gio')).rows[0].bay_gio;

    const veThang = (await client.query(
      `SELECT id FROM ve_thang
        WHERE xe_id = $1 AND bai_xe_id = $2 AND trang_thai = 'hieu_luc'
          AND current_date BETWEEN ngay_bat_dau AND ngay_het_han
        LIMIT 1`,
      [lg.xe_id, lg.bai_xe_id],
    )).rows[0];

    let soGio = 0;
    let soTien = 0;
    if (!veThang) {
      const gia = (await client.query(
        'SELECT gia_theo_gio, gia_toi_da_ngay FROM bang_gia WHERE bai_xe_id = $1 AND loai_xe = $2',
        [lg.bai_xe_id, lg.loai_xe],
      )).rows[0];
      if (!gia) throw new HttpError(409, 'Bãi chưa có bảng giá cho loại xe này');
      ({ soGio, soTien } = tinhTien({
        gioVao: lg.gio_vao, gioRa, giaTheoGio: gia.gia_theo_gio, giaToiDaNgay: gia.gia_toi_da_ngay,
      }));
    }

    const { rows } = await client.query(
      `UPDATE luot_gui SET gio_ra = $2, so_tien = $3, trang_thai = 'da_ra'
        WHERE id = $1 RETURNING id, gio_vao, gio_ra, so_tien, trang_thai`,
      [luotId, gioRa, soTien],
    );
    if (soTien > 0) {
      await client.query(
        'INSERT INTO thanh_toan (luot_gui_id, so_tien, phuong_thuc) VALUES ($1, $2, $3)',
        [luotId, soTien, phuongThuc],
      );
    }
    await client.query("UPDATE cho_do SET trang_thai = 'trong' WHERE id = $1", [lg.cho_do_id]);
    return { ...rows[0], so_gio: soGio, mien_phi_ve_thang: Boolean(veThang) };
  });
  res.json(ketQua);
}));

module.exports = router;
