# client-flutter – App Client Bãi giữ xe thông minh

Flutter 3.35+ / Dart 3. Gọi API backend Node.js (Express + pg) trên Render, ảnh lưu ở Supabase Storage.

## Chạy

```bash
cd client-flutter
flutter create --org com.example --platforms=android,ios .   # sinh thư mục android/ ios/ (không ghi đè lib/, test/)
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_URL=https://<ten-app>.onrender.com/api
```

Android: kiểm tra `android/app/src/main/AndroidManifest.xml` có
`<uses-permission android:name="android.permission.INTERNET"/>` (bản release cần dòng này).
Render Free "ngủ" sau 15 phút nên lần gọi đầu có thể chậm (timeout đặt 60 giây).

## Đối chiếu yêu cầu

| Yêu cầu | Nằm ở đâu |
|---|---|
| Đăng nhập, lưu token bằng shared_preferences | `screens/login_screen.dart`, `core/token_storage.dart`; Splash tự vào Home nếu đã có token |
| Navigator nhiều màn hình, trả kết quả về màn trước | Register → Login (email); VehicleForm → VehiclesTab (`Vehicle`); Booking → LotDetail → LotsTab (`Booking`) |
| ≥ 2 danh sách `ListView.builder` tải từ API | `lots_tab.dart` (GET /lots), `vehicles_tab.dart` (GET /vehicles), `booking_history_screen.dart` (GET /bookings) |
| Form + validator | Login, Register, VehicleForm, Booking – `core/validators.dart` |
| Scaffold + NavigationBar | `screens/home_shell.dart` |
| SnackBar có Hoàn tác khi xóa | `vehicles_tab.dart` → `_deleteWithUndo` (vuốt xe sang trái) |
| Ảnh từ URL có loadingBuilder + errorBuilder | `widgets/app_network_image.dart` |
| Kiểm tra `mounted` sau mỗi `await` | mọi `State` đều có `if (!mounted) return;`; widget Stateless dùng `context.mounted` |
| Tối thiểu 6 màn hình | Splash, Login, Register, Home (3 tab), LotDetail, VehicleForm, Booking, BookingHistory = 8 |

## Hợp đồng API mà app mong đợi

Header: `Authorization: Bearer <JWT>` (trừ login/register). Lỗi trả `{ "message": "..." }` kèm mã 4xx/5xx; 401 khi đã có token sẽ tự đăng xuất.
Danh sách có thể là `[...]` hoặc `{ "data": [...] }`. Số `NUMERIC` của PostgreSQL trả dạng chuỗi vẫn đọc được.

| Method | Path | Body | Trả về |
|---|---|---|---|
| POST | /auth/login | `email, password` | `{ token, user: {id, full_name, email, phone} }` |
| POST | /auth/register | `full_name, email, phone, password` | 201 (nội dung bất kỳ) |
| GET | /auth/me | – | `{id, full_name, email, phone}` |
| GET | /lots | – | `[{id, name, address, total_slots, available_slots, price_per_hour, image_url, description}]` |
| GET | /vehicles | – | `[{id, plate, type: 'car'\|'motorbike', brand, color}]` |
| POST | /vehicles | `plate, type, brand, color` | xe vừa tạo |
| PUT | /vehicles/:id | như trên | xe đã sửa |
| DELETE | /vehicles/:id | – | 200/204 |
| GET | /bookings | – | `[{id, lot_name, plate, hours, total_price, status: 'active'\|'completed'\|'cancelled', created_at}]` |
| POST | /bookings | `lot_id, vehicle_id, hours` | lượt đặt vừa tạo |

Nếu backend của bạn đặt tên field/đường dẫn khác, chỉ cần sửa `lib/models/*.dart` và `lib/services/parking_service.dart`.

## Cấu trúc

```
lib/
  main.dart                 routes + xử lý 401 toàn cục
  core/                     config, token_storage, api_client, validators, format
  models/                   app_user, parking_lot, vehicle, booking
  services/parking_service.dart
  widgets/                  app_network_image, list_state_view, snack
  screens/                  splash, login, register, home_shell, lots_tab,
                            vehicles_tab, profile_tab, lot_detail,
                            vehicle_form, booking, booking_history
test/widget_test.dart       test validator, format, model
```
