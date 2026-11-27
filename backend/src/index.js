require('dotenv').config({ quiet: true });
const express = require('express');
const cors = require('cors');
const { query } = require('./db');

if (!process.env.JWT_SECRET) {
  console.error('Thiếu JWT_SECRET trong file .env');
  process.exit(1);
}

const app = express();
app.use(cors());
app.use(express.json());

// Kiểm tra server và database còn sống (Render dùng được cho health check)
app.get('/', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({ ten: 'API Giữ xe thông minh', trang_thai: 'ok' });
  } catch (err) {
    res.status(503).json({ loi: 'Không kết nối được database' });
  }
});

app.use('/api/auth', require('./routes/auth'));
app.use('/api/nguoi-dung', require('./routes/nguoi-dung'));
app.use('/api/xe', require('./routes/xe'));
app.use('/api/bai-xe', require('./routes/bai-xe'));
app.use('/api/dat-cho', require('./routes/dat-cho'));
app.use('/api/luot-gui', require('./routes/luot-gui'));
app.use('/api/ve-thang', require('./routes/ve-thang'));
app.use('/api/thong-ke', require('./routes/thong-ke'));

app.use((req, res) => res.status(404).json({ loi: 'Không tìm thấy đường dẫn này' }));

// Bộ xử lý lỗi chung: mọi lỗi đều trả về dạng { "loi": "..." }
const RANG_BUOC = {
  uq_luot_gui_xe_dang_gui: 'Xe này đang gửi trong bãi, chưa ra',
  uq_luot_gui_cho_dang_gui: 'Chỗ đỗ này đang có xe',
};
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  if (err.status) return res.status(err.status).json({ loi: err.message });
  if (err.type === 'entity.parse.failed') return res.status(400).json({ loi: 'Dữ liệu JSON gửi lên bị sai cú pháp' });
  if (err.code === '23505') return res.status(409).json({ loi: RANG_BUOC[err.constraint] || 'Dữ liệu bị trùng với bản ghi đã có' });
  if (err.code === '23503') return res.status(409).json({ loi: 'Dữ liệu đang được liên kết hoặc tham chiếu tới bản ghi không tồn tại' });
  if (err.code === '22P02' || err.code === '22007' || err.code === '23514') return res.status(400).json({ loi: 'Dữ liệu không hợp lệ' });
  console.error(err);
  return res.status(500).json({ loi: 'Lỗi máy chủ' });
});

const PORT = process.env.PORT || 3000;
if (require.main === module) {
  app.listen(PORT, () => console.log(`API đang chạy tại http://localhost:${PORT}`));
}

module.exports = app;
