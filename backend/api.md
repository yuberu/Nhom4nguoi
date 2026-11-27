# Tài liệu API - Hệ thống quản lý giữ xe thông minh

- **Địa chỉ gốc (base URL):** `http://localhost:3000` khi chạy máy cá nhân. Sau khi deploy sẽ là địa chỉ Render (ghi vào mục "Địa chỉ đã deploy" ở cuối file).
- **Định dạng:** gửi và nhận JSON. Khi gửi dữ liệu phải có header `Content-Type: application/json`.
- **Đăng nhập:** gọi `POST /api/auth/login` để lấy `token`, các API còn lại gửi kèm header `Authorization: Bearer <token>`. Token hết hạn sau 1 ngày.
- **Lỗi** luôn có dạng `{ "loi": "Nội dung lỗi bằng tiếng Việt" }`.

## Mã trạng thái

| Mã | Ý nghĩa |
|---|---|
| 200 | Thành công |
| 201 | Tạo mới thành công |
| 204 | Xóa thành công (không có nội dung trả về) |
| 400 | Dữ liệu gửi lên sai hoặc thiếu |
| 401 | Chưa đăng nhập, token sai hoặc hết hạn |
| 403 | Đã đăng nhập nhưng không đủ quyền |
| 404 | Không tìm thấy |
| 409 | Xung đột (trùng dữ liệu, chỗ đã có người, thao tác không còn hợp lệ) |
| 500 | Lỗi máy chủ |

## Vai trò

`admin` (quản trị), `nhan_vien` (nhân viên bãi), `khach_hang` (khách). Quyền được kiểm tra **ở server**, ẩn nút trên app không thay thế được.

## Tài khoản mẫu (mật khẩu đều là `123456`)

`admin`, `nv01`, `kh01`, `kh02`

---

## 1. Đăng nhập, tài khoản

| Method | Đường dẫn | Quyền | Mô tả |
|---|---|---|---|
| POST | `/api/auth/register` | Công khai | Khách tự đăng ký |
| POST | `/api/auth/login` | Công khai | Đăng nhập, nhận token |
| GET | `/api/auth/me` | Đã đăng nhập | Thông tin của mình |

**POST /api/auth/register** - gửi `{ "ten_dang_nhap": "abc", "mat_khau": "123456", "ho_ten": "Nguyễn A", "email": "a@x.com", "so_dien_thoai": "0900000000" }`. `email`, `so_dien_thoai` không bắt buộc. Trả 201 kèm thông tin tài khoản; 409 nếu trùng tên đăng nhập hoặc email.

**POST /api/auth/login** - gửi `{ "ten_dang_nhap": "kh01", "mat_khau": "123456" }`. Trả 200:
```json
{
  "token": "eyJhbGciOi...",
  "nguoi_dung": { "id": 3, "ten_dang_nhap": "kh01", "ho_ten": "Trần Thị Bình", "anh_dai_dien": null, "vai_tro": "khach_hang" }
}
```
Sai tên hoặc mật khẩu: 401.

## 2. Người dùng (chỉ admin)

| Method | Đường dẫn | Mô tả |
|---|---|---|
| GET | `/api/nguoi-dung?vai_tro=khach_hang` | Danh sách người dùng (lọc theo vai trò, không bắt buộc) |
| PATCH | `/api/nguoi-dung/:id/vai-tro` | Đổi vai trò, gửi `{ "vai_tro": "nhan_vien" }` |
| DELETE | `/api/nguoi-dung/:id` | Xóa người dùng (204). Không tự xóa mình; 409 nếu còn dữ liệu liên quan |

## 3. Xe

| Method | Đường dẫn | Quyền | Mô tả |
|---|---|---|---|
| GET | `/api/xe` | Đã đăng nhập | Khách thấy xe của mình, nhân viên/admin thấy tất cả |
| POST | `/api/xe` | Đã đăng nhập | Đăng ký xe: `{ "bien_so": "59A1-99999", "loai_xe": "xe_may", "hang_xe": "Honda" }`. Nhân viên/admin thêm `"nguoi_dung_id": 3` |
| DELETE | `/api/xe/:id` | Chủ xe hoặc admin | Xóa xe (204) |

`loai_xe` chỉ nhận `xe_may` hoặc `o_to`.

## 4. Bãi xe, chỗ đỗ, bảng giá

| Method | Đường dẫn | Quyền | Mô tả |
|---|---|---|---|
| GET | `/api/bai-xe` | Đã đăng nhập | Danh sách bãi kèm `tong_cho`, `cho_trong` |
| GET | `/api/bai-xe/:id` | Đã đăng nhập | Chi tiết bãi kèm `bang_gia` |
| GET | `/api/bai-xe/:id/cho-do?trang_thai=trong&loai_xe=o_to` | Đã đăng nhập | Danh sách chỗ đỗ (hai bộ lọc không bắt buộc) |
| POST | `/api/bai-xe` | admin | Thêm bãi: `{ "ten": "...", "dia_chi": "...", "anh_url": "https://..." }` |
| PUT | `/api/bai-xe/:id` | admin | Sửa bãi, thêm `"trang_thai": "hoat_dong"` hoặc `"dong_cua"` |
| DELETE | `/api/bai-xe/:id` | admin | Xóa bãi (204), 409 nếu bãi còn dữ liệu liên quan |
| POST | `/api/bai-xe/:id/cho-do` | admin | Thêm chỗ đỗ: `{ "ma_cho": "M11", "loai_xe": "xe_may" }` |
| PUT | `/api/bai-xe/:id/bang-gia` | admin | Đặt giá: `{ "loai_xe": "xe_may", "gia_theo_gio": 5000, "gia_toi_da_ngay": 30000, "gia_ve_thang": 300000 }` |

`trang_thai` của chỗ đỗ: `trong`, `da_dat`, `dang_dung`, `bao_tri`.

## 5. Đặt chỗ

| Method | Đường dẫn | Quyền | Mô tả |
|---|---|---|---|
| GET | `/api/dat-cho?trang_thai=da_dat` | Đã đăng nhập | Khách thấy của mình, nhân viên/admin thấy tất cả |
| POST | `/api/dat-cho` | Đã đăng nhập | Đặt chỗ |
| PATCH | `/api/dat-cho/:id/huy` | Chủ đặt chỗ, nhân viên, admin | Hủy, chỗ đỗ trở về trống |

**POST /api/dat-cho** - gửi `{ "xe_id": 1, "cho_do_id": 5, "bat_dau": "2026-12-01T08:00:00Z", "het_han": "2026-12-01T12:00:00Z" }`. Trả 201. 409 nếu chỗ không còn trống, 400 nếu loại xe không hợp lệ hoặc `het_han` không sau `bat_dau`.

## 6. Lượt gửi xe

| Method | Đường dẫn | Quyền | Mô tả |
|---|---|---|---|
| GET | `/api/luot-gui?trang_thai=dang_gui&bai_xe_id=1&limit=50&offset=0` | Đã đăng nhập | Khách thấy của mình, nhân viên/admin thấy tất cả |
| GET | `/api/luot-gui/:id` | Đã đăng nhập | Chi tiết một lượt gửi |
| POST | `/api/luot-gui/vao` | nhân viên, admin | Cho xe vào bãi |
| POST | `/api/luot-gui/:id/ra` | nhân viên, admin | Cho xe ra, tính tiền, thu tiền |

**POST /api/luot-gui/vao** - gửi `{ "bien_so": "59A1-12345", "bai_xe_id": 1 }` để hệ thống tự chọn chỗ trống phù hợp, hoặc `"cho_do_id": 5` để chọn chỗ cụ thể. Nếu xe có đặt chỗ trước, thêm `"dat_cho_id"`. Trả 201. Lỗi: 404 xe chưa đăng ký, 409 xe đang gửi hoặc bãi hết chỗ.

**POST /api/luot-gui/:id/ra** - gửi `{ "phuong_thuc": "tien_mat" }` (`tien_mat`, `chuyen_khoan`, `vi_dien_tu`; mặc định `tien_mat`). Trả 200:
```json
{ "id": 7, "gio_vao": "...", "gio_ra": "...", "so_tien": 10000, "trang_thai": "da_ra", "so_gio": 2, "mien_phi_ve_thang": false }
```
Đây là nghiệp vụ dùng **giao dịch (transaction)**: chốt giờ ra, tính tiền, ghi thanh toán và trả chỗ đỗ về trống chạy cùng nhau, lỗi ở bước nào thì hoàn tác tất cả.

**Cách tính tiền:** làm tròn lên theo giờ, tối thiểu 1 giờ; mỗi 24 giờ tính bằng mức `gia_toi_da_ngay`; phần giờ lẻ tính theo `gia_theo_gio` nhưng không vượt `gia_toi_da_ngay`. Xe có vé tháng còn hiệu lực ở bãi đó ra miễn phí (`so_tien` = 0).

## 7. Vé tháng

| Method | Đường dẫn | Quyền | Mô tả |
|---|---|---|---|
| GET | `/api/ve-thang` | Đã đăng nhập | Khách thấy của mình, nhân viên/admin thấy tất cả |
| POST | `/api/ve-thang` | Đã đăng nhập | Mua vé: `{ "xe_id": 2, "bai_xe_id": 1, "so_thang": 1, "phuong_thuc": "chuyen_khoan" }` |
| PATCH | `/api/ve-thang/:id/huy` | nhân viên, admin | Hủy vé đang hiệu lực |

`so_thang` từ 1 đến 12 (mặc định 1). Mỗi tháng tính 30 ngày. 409 nếu xe đang có vé còn hiệu lực ở bãi đó.

## 8. Thống kê (chỉ admin, dùng cho biểu đồ ở App Admin)

| Method | Đường dẫn | Dữ liệu trả về |
|---|---|---|
| GET | `/api/thong-ke/tong-quan` | `{ so_bai_xe, tong_cho, cho_trong, xe_dang_gui, so_nguoi_dung, doanh_thu_hom_nay }` |
| GET | `/api/thong-ke/doanh-thu?so_ngay=7` | `[ { "ngay": "2026-11-23", "doanh_thu": 15000 }, ... ]` (1 đến 90 ngày) |
| GET | `/api/thong-ke/luot-gui-theo-bai` | `[ { "bai_xe_id": 1, "ten": "...", "so_luot": 2 }, ... ]` |

## Địa chỉ đã deploy

(Điền địa chỉ Render vào đây sau khi deploy.)
