
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/db.js';

// ĐĂNG KÝ TÀI KHOẢN
export const dangKy = async (req, res) => {
  try {
    const { email, matKhau, hoTen } = req.body;

    // Kiểm tra dữ liệu đầu vào
    if (!email || !matKhau) {
      return res.status(400).json({
        loi: 'Vui lòng nhập email và mật khẩu',
      });
    }

    const emailChuanHoa = email.trim().toLowerCase();

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailChuanHoa)) {
      return res.status(400).json({
        loi: 'Email không hợp lệ',
      });
    }

    if (typeof matKhau !== 'string' || matKhau.length < 8) {
      return res.status(400).json({
        loi: 'Mật khẩu phải có ít nhất 8 ký tự',
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
      nguoiDung: result.rows[0],
    });

  } catch (error) {
    console.error('Lỗi đăng ký:', error.message);

    if (error.code === '23505') {
      return res.status(409).json({
        loi: 'Email đã tồn tại',
      });
    }

    return res.status(500).json({
      loi: 'Lỗi máy chủ khi đăng ký tài khoản',
    });
  }
};


// ĐĂNG NHẬP
export const dangNhap = async (req, res) => {
  try {
    const { email, matKhau } = req.body;

    if (!email || !matKhau) {
      return res.status(400).json({
        loi: 'Vui lòng nhập email và mật khẩu',
      });
    }

    if (typeof email !== 'string' || typeof matKhau !== 'string') {
      return res.status(400).json({
        loi: 'Dữ liệu đăng nhập không hợp lệ',
      });
    }

    const emailChuanHoa = email.trim().toLowerCase();

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
        loi: 'Email hoặc mật khẩu không đúng',
      });
    }

    // Kiểm tra JWT_SECRET
    if (!process.env.JWT_SECRET) {
      console.error('Chưa cấu hình JWT_SECRET');
      return res.status(500).json({
        loi: 'Máy chủ chưa cấu hình xác thực',
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
      loi: 'Lỗi máy chủ khi đăng nhập',
    });
  }
};
