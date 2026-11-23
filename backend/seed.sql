-- Dữ liệu mẫu. Chạy sau schema.sql:  psql -d <ten_db> -f seed.sql
-- Mật khẩu của TẤT CẢ tài khoản mẫu là: 123456

INSERT INTO vai_tro (ten) VALUES ('admin'), ('nhan_vien'), ('khach_hang');

INSERT INTO nguoi_dung (ten_dang_nhap, mat_khau_hash, ho_ten, email, so_dien_thoai, vai_tro_id) VALUES
 ('admin',  '$2b$10$g27vkz36yN.6eExNv863euYL/Yx5SkYLiT3RKdfy/GJ1S4ctK4Raq', 'Quản trị viên',  'admin@giuxe.vn',  '0900000001', (SELECT id FROM vai_tro WHERE ten = 'admin')),
 ('nv01',   '$2b$10$g27vkz36yN.6eExNv863euYL/Yx5SkYLiT3RKdfy/GJ1S4ctK4Raq', 'Nguyễn Văn An',  'nv01@giuxe.vn',   '0900000002', (SELECT id FROM vai_tro WHERE ten = 'nhan_vien')),
 ('kh01',   '$2b$10$g27vkz36yN.6eExNv863euYL/Yx5SkYLiT3RKdfy/GJ1S4ctK4Raq', 'Trần Thị Bình',  'kh01@gmail.com',  '0900000003', (SELECT id FROM vai_tro WHERE ten = 'khach_hang')),
 ('kh02',   '$2b$10$g27vkz36yN.6eExNv863euYL/Yx5SkYLiT3RKdfy/GJ1S4ctK4Raq', 'Lê Văn Cường',   'kh02@gmail.com',  '0900000004', (SELECT id FROM vai_tro WHERE ten = 'khach_hang'));

INSERT INTO xe (nguoi_dung_id, bien_so, loai_xe, hang_xe) VALUES
 ((SELECT id FROM nguoi_dung WHERE ten_dang_nhap = 'kh01'), '59A1-12345', 'xe_may', 'Honda'),
 ((SELECT id FROM nguoi_dung WHERE ten_dang_nhap = 'kh01'), '51F-67890',  'o_to',   'Toyota'),
 ((SELECT id FROM nguoi_dung WHERE ten_dang_nhap = 'kh02'), '59B2-54321', 'xe_may', 'Yamaha');

INSERT INTO bai_xe (ten, dia_chi, anh_url) VALUES
 ('Bãi xe Nguyễn Huệ', '12 Nguyễn Huệ, Quận 1, TP.HCM', 'https://picsum.photos/seed/baixe1/600/400'),
 ('Bãi xe Lê Lợi',     '45 Lê Lợi, Quận 1, TP.HCM',     'https://picsum.photos/seed/baixe2/600/400');

-- Mỗi bãi: 10 chỗ xe máy (M01-M10) và 5 chỗ ô tô (O01-O05)
INSERT INTO cho_do (bai_xe_id, ma_cho, loai_xe)
SELECT b.id, 'M' || lpad(g::text, 2, '0'), 'xe_may' FROM bai_xe b, generate_series(1, 10) g;
INSERT INTO cho_do (bai_xe_id, ma_cho, loai_xe)
SELECT b.id, 'O' || lpad(g::text, 2, '0'), 'o_to' FROM bai_xe b, generate_series(1, 5) g;

INSERT INTO bang_gia (bai_xe_id, loai_xe, gia_theo_gio, gia_toi_da_ngay, gia_ve_thang)
SELECT id, 'xe_may', 5000, 30000, 300000 FROM bai_xe;
INSERT INTO bang_gia (bai_xe_id, loai_xe, gia_theo_gio, gia_toi_da_ngay, gia_ve_thang)
SELECT id, 'o_to', 20000, 120000, 1500000 FROM bai_xe;

-- 1 lượt gửi đã hoàn thành (xe máy của kh01, 3 giờ, 15.000đ) và 1 lượt đang gửi
INSERT INTO luot_gui (xe_id, cho_do_id, nhan_vien_id, gio_vao, gio_ra, so_tien, trang_thai) VALUES
 ((SELECT id FROM xe WHERE bien_so = '59A1-12345'),
  (SELECT id FROM cho_do WHERE ma_cho = 'M01' AND bai_xe_id = (SELECT id FROM bai_xe WHERE ten = 'Bãi xe Nguyễn Huệ')),
  (SELECT id FROM nguoi_dung WHERE ten_dang_nhap = 'nv01'),
  now() - interval '2 days', now() - interval '2 days' + interval '3 hours', 15000, 'da_ra'),
 ((SELECT id FROM xe WHERE bien_so = '59B2-54321'),
  (SELECT id FROM cho_do WHERE ma_cho = 'M02' AND bai_xe_id = (SELECT id FROM bai_xe WHERE ten = 'Bãi xe Nguyễn Huệ')),
  (SELECT id FROM nguoi_dung WHERE ten_dang_nhap = 'nv01'),
  now() - interval '1 hour', NULL, NULL, 'dang_gui');

UPDATE cho_do SET trang_thai = 'dang_dung'
 WHERE ma_cho = 'M02' AND bai_xe_id = (SELECT id FROM bai_xe WHERE ten = 'Bãi xe Nguyễn Huệ');

INSERT INTO thanh_toan (luot_gui_id, so_tien, phuong_thuc, tao_luc)
SELECT id, 15000, 'tien_mat', gio_ra FROM luot_gui WHERE trang_thai = 'da_ra';

INSERT INTO ve_thang (xe_id, bai_xe_id, ngay_bat_dau, ngay_het_han, gia)
VALUES ((SELECT id FROM xe WHERE bien_so = '51F-67890'),
        (SELECT id FROM bai_xe WHERE ten = 'Bãi xe Lê Lợi'),
        current_date, current_date + 29, 1500000);

INSERT INTO thanh_toan (ve_thang_id, so_tien, phuong_thuc)
SELECT id, 1500000, 'chuyen_khoan' FROM ve_thang;

-- 1 đặt chỗ ô tô cho ngày mai
INSERT INTO dat_cho (nguoi_dung_id, xe_id, cho_do_id, bat_dau, het_han)
VALUES ((SELECT id FROM nguoi_dung WHERE ten_dang_nhap = 'kh01'),
        (SELECT id FROM xe WHERE bien_so = '51F-67890'),
        (SELECT id FROM cho_do WHERE ma_cho = 'O01' AND bai_xe_id = (SELECT id FROM bai_xe WHERE ten = 'Bãi xe Lê Lợi')),
        now() + interval '1 day', now() + interval '1 day 4 hours');
UPDATE cho_do SET trang_thai = 'da_dat'
 WHERE ma_cho = 'O01' AND bai_xe_id = (SELECT id FROM bai_xe WHERE ten = 'Bãi xe Lê Lợi');
