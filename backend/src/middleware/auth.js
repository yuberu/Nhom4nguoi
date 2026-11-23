const jwt = require('jsonwebtoken');

// Bắt buộc có token hợp lệ (header: Authorization: Bearer <token>).
function xacThuc(req, res, next) {
  const [kieu, token] = (req.headers.authorization || '').split(' ');
  if (kieu !== 'Bearer' || !token) {
    return res.status(401).json({ loi: 'Thiếu token đăng nhập' });
  }
  try {
    req.nguoiDung = jwt.verify(token, process.env.JWT_SECRET);
    return next();
  } catch (err) {
    return res.status(401).json({ loi: 'Token không hợp lệ hoặc đã hết hạn' });
  }
}

// Phân quyền Ở SERVER: chỉ cho các vai trò được liệt kê đi tiếp.
function phanQuyen(...cacVaiTro) {
  return (req, res, next) => {
    if (!cacVaiTro.includes(req.nguoiDung.vai_tro)) {
      return res.status(403).json({ loi: 'Bạn không có quyền thực hiện thao tác này' });
    }
    return next();
  };
}

module.exports = { xacThuc, phanQuyen };
