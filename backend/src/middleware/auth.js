
import jwt from 'jsonwebtoken';

export const xacThuc = (req, res, next) => {
  try {
    // Lấy token từ Header Authorization
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        thanhCong: false,
        loi: 'Vui lòng đăng nhập để tiếp tục',
      });
    }

    const token = authHeader.split(' ')[1];

    // Kiểm tra JWT_SECRET
    if (!process.env.JWT_SECRET) {
      return res.status(500).json({
        thanhCong: false,
        loi: 'Máy chủ chưa cấu hình JWT_SECRET',
      });
    }

    // Xác thực token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Lưu thông tin người dùng vào request
    req.nguoiDung = decoded;

    next();
  } catch (error) {
    return res.status(401).json({
      thanhCong: false,
      loi: 'Token không hợp lệ hoặc đã hết hạn',
    });
  }
};
