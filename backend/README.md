# Backend - Hệ thống quản lý giữ xe thông minh

Node.js + Express + PostgreSQL. Tài liệu các API xem trong [api.md](api.md).

## Chạy trên máy cá nhân

1. Cài Node.js (bản LTS) và PostgreSQL.
2. Trong thư mục `backend`:
   ```
   npm install
   copy .env.example .env
   ```
   Mở file `.env`, sửa `DATABASE_URL` (mật khẩu PostgreSQL của bạn) và `JWT_SECRET`.
3. Tạo database (một lần): `psql -U postgres -c "CREATE DATABASE giuxe;"`
4. Nạp bảng và dữ liệu mẫu: `npm run db:init` (xóa bảng cũ rồi tạo lại)
5. Chạy server: `npm run dev` rồi mở http://localhost:3000
6. Kiểm tra toàn bộ API (khi server đang chạy, mở cửa sổ khác): `npm run smoke`

## Cấu trúc

- `schema.sql`, `seed.sql`: 10 bảng và dữ liệu mẫu, chạy lại từ đầu được
- `src/index.js`: khởi động server, xử lý lỗi chung
- `src/db.js`: kết nối PostgreSQL, hàm chạy giao dịch
- `src/middleware/auth.js`: kiểm tra token JWT và phân quyền theo vai trò
- `src/routes/`: các nhóm API (auth, nguoi-dung, xe, bai-xe, dat-cho, luot-gui, ve-thang, thong-ke)
- `scripts/init-db.js`, `scripts/smoke-test.js`: nạp database và kiểm tra nhanh

## Biến môi trường

| Tên | Ý nghĩa |
|---|---|
| `PORT` | Cổng chạy server (Render tự cấp) |
| `DATABASE_URL` | Địa chỉ kết nối PostgreSQL |
| `DATABASE_SSL` | `true` khi dùng database trên Render |
| `JWT_SECRET` | Chuỗi bí mật ký token, giữ kín, không đưa lên GitHub |
| `JWT_EXPIRES_IN` | Thời hạn token, mặc định `1d` |
