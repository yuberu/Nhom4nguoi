const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query } = require('../db');
const { xacThuc } = require('../middleware/auth');
const { HttpError, boc, batBuocChuoi } = require('../utils/http');

// POST /api/auth/register - khách tự đăng ký (luôn là vai trò khach_hang)
router.post('/register', boc(async (req, res) => {
  const tenDangNhap = batBuocChuoi(req.body.ten_dang_nhap, 'ten_dang_nhap', 3, 50);
  const matKhau = batBuocChuoi(req.body.mat_khau, 'mat_khau', 6, 72);
  const hoTen = batBuocChuoi(req.body.ho_ten, 'ho_ten', 2, 100);
  const email = req.body.email ? batBuocChuoi(req.body.email, 'email', 5, 100) : null;
  const soDienThoai = req.body.so_dien_thoai ? batBuocChuoi(req.body.so_dien_thoai, 'so_dien_thoai', 8, 20) : null;
  if (email && !/^\S+@\S+\.\S+$/.test(email)) throw new HttpError(400, 'email không hợp lệ');

  const hash = await bcrypt.hash(matKhau, 10);
  const { rows } = await query(
    `INSERT INTO nguoi_dung (ten_dang_nhap, mat_khau_hash, ho_ten, email, so_dien_thoai, vai_tro_id)
     VALUES ($1, $2, $3, $4, $5, (SELECT id FROM vai_tro WHERE ten = 'khach_hang'))
     RETURNING id, ten_dang_nhap, ho_ten, email, so_dien_thoai`,
    [tenDangNhap, hash, hoTen, email, soDienThoai],
  );
  res.status(201).json(rows[0]);
}));

// POST /api/auth/login - trả về token JWT
router.post('/login', boc(async (req, res) => {
  const tenDangNhap = batBuocChuoi(req.body.ten_dang_nhap, 'ten_dang_nhap', 1, 50);
  const matKhau = batBuocChuoi(req.body.mat_khau, 'mat_khau', 1, 72);

  const { rows } = await query(
    `SELECT nd.id, nd.ten_dang_nhap, nd.mat_khau_hash, nd.ho_ten, nd.anh_dai_dien, vt.ten AS vai_tro
       FROM nguoi_dung nd JOIN vai_tro vt ON vt.id = nd.vai_tro_id
      WHERE nd.ten_dang_nhap = $1`,
    [tenDangNhap],
  );
  const nd = rows[0];
  // Cùng một thông báo cho "sai tên" và "sai mật khẩu" để không lộ tài khoản nào tồn tại.
  if (!nd || !(await bcrypt.compare(matKhau, nd.mat_khau_hash))) {
    throw new HttpError(401, 'Sai tên đăng nhập hoặc mật khẩu');
  }
  const token = jwt.sign({ id: nd.id, vai_tro: nd.vai_tro }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '1d',
  });
  res.json({
    token,
    nguoi_dung: {
      id: nd.id, ten_dang_nhap: nd.ten_dang_nhap, ho_ten: nd.ho_ten,
      anh_dai_dien: nd.anh_dai_dien, vai_tro: nd.vai_tro,
    },
  });
}));

// GET /api/auth/me - thông tin người đang đăng nhập
router.get('/me', xacThuc, boc(async (req, res) => {
  const { rows } = await query(
    `SELECT nd.id, nd.ten_dang_nhap, nd.ho_ten, nd.email, nd.so_dien_thoai, nd.anh_dai_dien, vt.ten AS vai_tro
       FROM nguoi_dung nd JOIN vai_tro vt ON vt.id = nd.vai_tro_id
      WHERE nd.id = $1`,
    [req.nguoiDung.id],
  );
  if (!rows[0]) throw new HttpError(404, 'Không tìm thấy tài khoản');
  res.json(rows[0]);
}));

module.exports = router;
