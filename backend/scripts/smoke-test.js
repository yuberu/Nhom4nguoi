// Kiểm tra nhanh toàn bộ API. Cần server đang chạy và database đã nạp seed.
//   Cửa sổ 1:  npm run dev
//   Cửa sổ 2:  npm run smoke
// Chạy lại nhiều lần được: nên chạy  npm run db:init  trước để dữ liệu về trạng thái ban đầu.
const { tinhTien } = require('../src/utils/tinh-tien');

const BASE = process.env.BASE_URL || 'http://localhost:3000';
let dat = 0;
let hong = 0;

function kiemTra(ten, dieuKien, chiTiet = '') {
  if (dieuKien) { dat += 1; console.log(`  ✓ ${ten}`); } else { hong += 1; console.log(`  ✗ ${ten} ${chiTiet}`); }
}

async function goi(method, duongDan, token, body) {
  const res = await fetch(BASE + duongDan, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  let data = null;
  try { data = await res.json(); } catch (e) { /* 204 không có nội dung */ }
  return { status: res.status, data };
}

async function dangNhap(ten) {
  const r = await goi('POST', '/api/auth/login', null, { ten_dang_nhap: ten, mat_khau: '123456' });
  return r.data && r.data.token;
}

async function main() {
  console.log('Hàm tính tiền');
  const gia = { giaTheoGio: 5000, giaToiDaNgay: 30000 };
  const t0 = new Date('2026-01-01T08:00:00Z');
  const cong = (phut) => new Date(t0.getTime() + phut * 60000);
  kiemTra('30 phút tính 1 giờ = 5.000', tinhTien({ gioVao: t0, gioRa: cong(30), ...gia }).soTien === 5000);
  kiemTra('61 phút tính 2 giờ = 10.000', tinhTien({ gioVao: t0, gioRa: cong(61), ...gia }).soTien === 10000);
  kiemTra('10 giờ bị chặn ở mức tối đa 30.000', tinhTien({ gioVao: t0, gioRa: cong(600), ...gia }).soTien === 30000);
  kiemTra('25 giờ = 30.000 + 5.000', tinhTien({ gioVao: t0, gioRa: cong(1500), ...gia }).soTien === 35000);

  console.log('Đăng nhập và phân quyền');
  let r = await goi('GET', '/');
  kiemTra('GET / báo ok', r.status === 200 && r.data.trang_thai === 'ok', JSON.stringify(r.data));
  r = await goi('POST', '/api/auth/login', null, { ten_dang_nhap: 'admin', mat_khau: 'sai' });
  kiemTra('Sai mật khẩu -> 401', r.status === 401);
  r = await goi('GET', '/api/bai-xe');
  kiemTra('Không có token -> 401', r.status === 401);
  const admin = await dangNhap('admin');
  const nv = await dangNhap('nv01');
  const kh = await dangNhap('kh01');
  kiemTra('Đăng nhập admin, nv01, kh01 có token', Boolean(admin && nv && kh));
  r = await goi('GET', '/api/nguoi-dung', kh);
  kiemTra('Khách xem danh sách người dùng -> 403', r.status === 403);
  r = await goi('GET', '/api/nguoi-dung', admin);
  kiemTra('Admin xem danh sách người dùng -> 200', r.status === 200 && r.data.length >= 4);
  r = await goi('GET', '/api/auth/me', kh);
  kiemTra('GET /me trả vai trò khach_hang', r.status === 200 && r.data.vai_tro === 'khach_hang');

  console.log('Đăng ký');
  const tenMoi = `test${Date.now()}`;
  r = await goi('POST', '/api/auth/register', null, { ten_dang_nhap: tenMoi, mat_khau: '123456', ho_ten: 'Người Thử' });
  kiemTra('Đăng ký mới -> 201', r.status === 201, JSON.stringify(r.data));
  r = await goi('POST', '/api/auth/register', null, { ten_dang_nhap: tenMoi, mat_khau: '123456', ho_ten: 'Người Thử' });
  kiemTra('Đăng ký trùng tên -> 409', r.status === 409);
  r = await goi('POST', '/api/auth/register', null, { ten_dang_nhap: 'ab', mat_khau: '1', ho_ten: 'x' });
  kiemTra('Dữ liệu sai -> 400', r.status === 400);

  console.log('Bãi xe');
  r = await goi('GET', '/api/bai-xe', kh);
  kiemTra('Danh sách bãi có số chỗ trống', r.status === 200 && r.data.length >= 2 && r.data[0].cho_trong >= 0);
  const baiId = r.data[0].id;
  r = await goi('POST', '/api/bai-xe', kh, { ten: 'Bãi thử', dia_chi: '1 Đường Thử, TP.HCM' });
  kiemTra('Khách thêm bãi -> 403', r.status === 403);
  r = await goi('POST', '/api/bai-xe', admin, { ten: 'Bãi thử', dia_chi: '1 Đường Thử, TP.HCM' });
  kiemTra('Admin thêm bãi -> 201', r.status === 201);
  const baiThu = r.data.id;
  r = await goi('PUT', `/api/bai-xe/${baiThu}`, admin, { ten: 'Bãi thử sửa', dia_chi: '2 Đường Thử, TP.HCM', trang_thai: 'dong_cua' });
  kiemTra('Admin sửa bãi -> 200', r.status === 200 && r.data.trang_thai === 'dong_cua');
  r = await goi('DELETE', `/api/bai-xe/${baiThu}`, admin);
  kiemTra('Admin xóa bãi -> 204', r.status === 204);
  r = await goi('DELETE', `/api/bai-xe/${baiThu}`, admin);
  kiemTra('Xóa lại -> 404', r.status === 404);
  r = await goi('GET', '/api/bai-xe/abc', kh);
  kiemTra('id không phải số -> 400', r.status === 400);

  console.log('Đặt chỗ');
  r = await goi('GET', '/api/xe', kh);
  const xeMay = r.data.find((x) => x.loai_xe === 'xe_may');
  const xeOto = r.data.find((x) => x.loai_xe === 'o_to');
  kiemTra('Khách chỉ thấy xe của mình', r.status === 200 && r.data.every((x) => x.chu_xe === 'Trần Thị Bình'));
  r = await goi('GET', `/api/bai-xe/${baiId}/cho-do?trang_thai=trong&loai_xe=xe_may`, kh);
  const choTrong = r.data[2];
  const ngay = (gio) => new Date(Date.now() + gio * 3600000).toISOString();
  r = await goi('POST', '/api/dat-cho', kh, { xe_id: xeMay.id, cho_do_id: choTrong.id, bat_dau: ngay(24), het_han: ngay(26) });
  kiemTra('Đặt chỗ -> 201', r.status === 201, JSON.stringify(r.data));
  const datChoId = r.data && r.data.id;
  r = await goi('POST', '/api/dat-cho', kh, { xe_id: xeMay.id, cho_do_id: choTrong.id, bat_dau: ngay(24), het_han: ngay(26) });
  kiemTra('Đặt lại đúng chỗ đó -> 409', r.status === 409);
  r = await goi('POST', '/api/dat-cho', kh, { xe_id: xeMay.id, cho_do_id: choTrong.id, bat_dau: ngay(26), het_han: ngay(24) });
  kiemTra('Giờ kết thúc trước giờ bắt đầu -> 400', r.status === 400);
  r = await goi('PATCH', `/api/dat-cho/${datChoId}/huy`, kh);
  kiemTra('Hủy đặt chỗ -> 200', r.status === 200 && r.data.trang_thai === 'da_huy');
  r = await goi('GET', `/api/bai-xe/${baiId}/cho-do?trang_thai=trong&loai_xe=xe_may`, kh);
  kiemTra('Hủy xong chỗ trở lại trống', r.data.some((c) => c.id === choTrong.id));

  console.log('Xe vào / ra (giao dịch)');
  r = await goi('POST', '/api/luot-gui/vao', kh, { bien_so: xeMay.bien_so, bai_xe_id: baiId });
  kiemTra('Khách cho xe vào -> 403', r.status === 403);
  r = await goi('POST', '/api/luot-gui/vao', nv, { bien_so: xeMay.bien_so, bai_xe_id: baiId });
  kiemTra('Nhân viên cho xe vào -> 201', r.status === 201, JSON.stringify(r.data));
  const luotId = r.data && r.data.id;
  r = await goi('POST', '/api/luot-gui/vao', nv, { bien_so: xeMay.bien_so, bai_xe_id: baiId });
  kiemTra('Xe đang gửi vào lần nữa -> 409', r.status === 409);
  r = await goi('POST', '/api/luot-gui/vao', nv, { bien_so: 'KHONGCO-1', bai_xe_id: baiId });
  kiemTra('Biển số chưa đăng ký -> 404', r.status === 404);
  r = await goi('POST', `/api/luot-gui/${luotId}/ra`, nv, { phuong_thuc: 'tien_mat' });
  kiemTra('Cho xe ra tính 5.000 (dưới 1 giờ)', r.status === 200 && r.data.so_tien === 5000 && r.data.trang_thai === 'da_ra', JSON.stringify(r.data));
  r = await goi('POST', `/api/luot-gui/${luotId}/ra`, nv, {});
  kiemTra('Cho ra lần 2 -> 409', r.status === 409);
  r = await goi('GET', '/api/luot-gui?trang_thai=dang_gui', nv);
  const dangGui = r.data.find((l) => l.bien_so === '59B2-54321');
  r = await goi('POST', `/api/luot-gui/${dangGui.id}/ra`, nv, { phuong_thuc: 'chuyen_khoan' });
  kiemTra('Xe gửi sẵn trong seed ra có tiền > 0', r.status === 200 && r.data.so_tien > 0, JSON.stringify(r.data));
  r = await goi('GET', '/api/luot-gui', kh);
  kiemTra('Khách chỉ thấy lượt gửi của mình', r.status === 200 && r.data.every((l) => l.bien_so !== '59B2-54321'));

  console.log('Vé tháng');
  r = await goi('POST', '/api/ve-thang', kh, { xe_id: xeOto.id, bai_xe_id: baiId, so_thang: 2 });
  kiemTra('Mua vé tháng 2 tháng -> 201, giá 3.000.000', r.status === 201 && r.data.gia === 3000000, JSON.stringify(r.data));
  r = await goi('POST', '/api/ve-thang', kh, { xe_id: xeOto.id, bai_xe_id: baiId });
  kiemTra('Mua vé khi đang còn hiệu lực -> 409', r.status === 409);
  r = await goi('POST', '/api/luot-gui/vao', nv, { bien_so: xeOto.bien_so, bai_xe_id: baiId });
  const luotOto = r.data && r.data.id;
  r = await goi('POST', `/api/luot-gui/${luotOto}/ra`, nv, {});
  kiemTra('Xe có vé tháng ra miễn phí', r.status === 200 && r.data.so_tien === 0 && r.data.mien_phi_ve_thang === true, JSON.stringify(r.data));

  console.log('Thống kê');
  r = await goi('GET', '/api/thong-ke/tong-quan', admin);
  kiemTra('Tổng quan -> 200', r.status === 200 && r.data.tong_cho === 30, JSON.stringify(r.data));
  r = await goi('GET', '/api/thong-ke/doanh-thu?so_ngay=7', admin);
  kiemTra('Doanh thu 7 ngày có 7 dòng', r.status === 200 && r.data.length === 7);
  r = await goi('GET', '/api/thong-ke/luot-gui-theo-bai', admin);
  kiemTra('Lượt gửi theo bãi -> 200', r.status === 200 && r.data.length >= 2);
  r = await goi('GET', '/api/thong-ke/tong-quan', nv);
  kiemTra('Nhân viên xem thống kê -> 403', r.status === 403);

  console.log(`\nKết quả: ${dat} đạt, ${hong} lỗi`);
  process.exitCode = hong ? 1 : 0;
}

main().catch((err) => { console.error('Không chạy được:', err.message); process.exitCode = 1; });
