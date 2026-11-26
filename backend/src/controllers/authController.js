
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/db.js';

// ========================================
// 1. ĐĂNG KÝ TÀI KHOẢN
// ========================================
export const dangKy = async (req, res) => {
  try {
    const { email, matKhau, hoTen } = req.body;

    // Kiểm tra dữ liệu đầu vào
    if (!email || !matKhau) {
      return res.status(400).json({
        thanhCong: false,
        loi: 'Vui lòng nhập email và mật khẩu',
      });
    }

    if (
      typeof email !== 'string' ||
      typeof matKhau !== 'string'
    ) {
      return res.status(400).json({
        thanhCong: false,
        loi: 'Dữ liệu đăng ký không hợp lệ',
      });
    }

    const emailChuanHoa = email.trim().toLowerCase();

    // Kiểm tra định dạng email
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailChuanHoa)) {
      return res.status(400).json({
        thanhCong: false,
        loi: 'Email không hợp lệ',
      });
    }

    // Kiểm tra mật khẩu
    if (matKhau.length < 8) {
      return res.status(400).json({
        thanhCong: false,
        loi: 'Mật khẩu phải có ít nhất 8 ký tự',
      });
    }

    // Kiểm tra họ tên
    if (
      hoTen !== undefined &&
      hoTen !== null &&
      typeof hoTen !== 'string'
    ) {
      return res.status(400).json({
        thanhCong: false,
        loi: 'Họ tên không hợp lệ',
      });
    }

    // Kiểm tra JWT_SECRET
    if (!process.env.JWT_SECRET) {
      console.error('Chưa cấu hình JWT_SECRET');

      return res.status(500).json({
        thanhCong: false,
        loi: 'Máy chủ chưa cấu hình xác thực',
      });
    }

    // Mã hóa mật khẩu
    const matKhauHash = await bcrypt.hash(matKhau, 10);

    // Thêm người dùng vào PostgreSQL
    const result = await pool.query(
      `INSERT INTO nguoi_dung
        (email, mat_khau_hash, ho_ten, vai_tro)
       VALUES ($1, $2, $3, 'KHACH')
       RETURNING id, email, ho_ten, vai_tro`,
      [
        emailChuanHoa,
        matKhauHash,
        hoTen?.trim() || null,
      ]
    );

    return res.status(201).json({
      thanhCong: true,
      thongBao: 'Đăng ký tài khoản thành công',
      nguoiDung: {
        id: result.rows[0].id,
        email: result.rows[0].email,
        hoTen: result.rows[0].ho_ten,
        vaiTro: result.rows[0].vai_tro,
      },
    });

  } catch (error) {
    console.error('Lỗi đăng ký:', error.message);

    // Email đã tồn tại
    if (error.code === '23505') {
      return res.status(409).json({
        thanhCong: false,
        loi: 'Email đã tồn tại',
      });
    }

    return res.status(500).json({
      thanhCong: false,
      loi: 'Lỗi máy chủ khi đăng ký tài khoản',
    });
  }
};


// ========================================
// 2. ĐĂNG NHẬP
// ========================================
export const dangNhap = async (req, res) => {
  try {
    const { email, matKhau } = req.body;

    // Kiểm tra dữ liệu đầu vào
    if (!email || !matKhau) {
      return res.status(400).json({
        thanhCong: false,
        loi: 'Vui lòng nhập email và mật khẩu',
      });
    }

    if (
      typeof email !== 'string' ||
      typeof matKhau !== 'string'
    ) {
      return res.status(400).json({
        thanhCong: false,
        loi: 'Dữ liệu đăng nhập không hợp lệ',
      });
    }

    const emailChuanHoa = email.trim().toLowerCase();

    // Kiểm tra JWT_SECRET
    if (!process.env.JWT_SECRET) {
      console.error('Chưa cấu hình JWT_SECRET');

      return res.status(500).json({
        thanhCong: false,
        loi: 'Máy chủ chưa cấu hình xác thực',
      });
    }

    // Tìm người dùng
    const result = await pool.query(
      `SELECT id, email, mat_khau_hash, ho_ten, vai_tro
       FROM nguoi_dung
       WHERE email = $1`,
      [emailChuanHoa]
    );

    const nguoiDung = result.rows[0];

    // Kiểm tra tài khoản và mật khẩu
    if (
      !nguoiDung ||
      !(await bcrypt.compare(matKhau, nguoiDung.mat_khau_hash))
    ) {
      return res.status(401).json({
        thanhCong: false,
        loi: 'Email hoặc mật khẩu không đúng',
      });
    }

    // Tạo JWT Token
    const token = jwt.sign(
      {
        id: nguoiDung.id,
        vaiTro: nguoiDung.vai_tro,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '7d',
      }
    );

    return res.status(200).json({
      thanhCong: true,
      thongBao: 'Đăng nhập thành công',
      token,
      nguoiDung: {
        id: nguoiDung.id,
        email: nguoiDung.email,
        hoTen: nguoiDung.ho_ten,
        vaiTro: nguoiDung.vai_tro,
      },
    });

  } catch (error) {
    console.error('Lỗi đăng nhập:', error.message);

    return res.status(500).json({
      thanhCong: false,
      loi: 'Lỗi máy chủ khi đăng nhập',
    });
  }
};


// ========================================
// 3. LẤY THÔNG TIN NGƯỜI DÙNG HIỆN TẠI
// ========================================
export const layThongTinCaNhan = async (req, res) => {
  try {
    // ID lấy từ JWT sau khi xác thực
    const userId = req.nguoiDung.id;

    const result = await pool.query(
      `SELECT id, email, ho_ten, vai_tro
       FROM nguoi_dung
       WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        thanhCong: false,
        loi: 'Không tìm thấy tài khoản',
      });
    }

    const user = result.rows[0];

    return res.status(200).json({
      thanhCong: true,
      nguoiDung: {
        id: user.id,
        email: user.email,
        hoTen: user.ho_ten,
        vaiTro: user.vai_tro,
      },
    });

  } catch (error) {
    console.error('Lỗi lấy thông tin cá nhân:', error.message);

    return res.status(500).json({
      thanhCong: false,
      loi: 'Không thể lấy thông tin tài khoản',
    });
  }
};
