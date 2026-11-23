-- =====================================================================
-- Hệ thống quản lý giữ xe thông minh - PostgreSQL
-- Chạy lại được từ đầu: file này xóa bảng cũ (nếu có) rồi tạo mới.
-- Cách chạy:  psql -d <ten_db> -f schema.sql
-- =====================================================================

DROP TABLE IF EXISTS thanh_toan CASCADE;
DROP TABLE IF EXISTS ve_thang   CASCADE;
DROP TABLE IF EXISTS luot_gui   CASCADE;
DROP TABLE IF EXISTS dat_cho    CASCADE;
DROP TABLE IF EXISTS bang_gia   CASCADE;
DROP TABLE IF EXISTS cho_do     CASCADE;
DROP TABLE IF EXISTS bai_xe     CASCADE;
DROP TABLE IF EXISTS xe         CASCADE;
DROP TABLE IF EXISTS nguoi_dung CASCADE;
DROP TABLE IF EXISTS vai_tro    CASCADE;

-- 1. Vai trò: admin, nhan_vien, khach_hang
CREATE TABLE vai_tro (
  id   SERIAL PRIMARY KEY,
  ten  VARCHAR(30) NOT NULL UNIQUE
);

-- 2. Người dùng (mật khẩu lưu dạng băm bcrypt, không lưu plain text)
CREATE TABLE nguoi_dung (
  id             SERIAL PRIMARY KEY,
  ten_dang_nhap  VARCHAR(50)  NOT NULL UNIQUE,
  mat_khau_hash  VARCHAR(100) NOT NULL,
  ho_ten         VARCHAR(100) NOT NULL,
  email          VARCHAR(100) UNIQUE,
  so_dien_thoai  VARCHAR(20),
  anh_dai_dien   TEXT,
  vai_tro_id     INT NOT NULL REFERENCES vai_tro(id),
  tao_luc        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Xe của khách
CREATE TABLE xe (
  id            SERIAL PRIMARY KEY,
  nguoi_dung_id INT NOT NULL REFERENCES nguoi_dung(id) ON DELETE CASCADE,
  bien_so       VARCHAR(20) NOT NULL UNIQUE,
  loai_xe       VARCHAR(10) NOT NULL CHECK (loai_xe IN ('xe_may', 'o_to')),
  hang_xe       VARCHAR(50)
);

-- 4. Bãi xe
CREATE TABLE bai_xe (
  id         SERIAL PRIMARY KEY,
  ten        VARCHAR(100) NOT NULL,
  dia_chi    VARCHAR(200) NOT NULL,
  anh_url    TEXT,
  trang_thai VARCHAR(15) NOT NULL DEFAULT 'hoat_dong'
             CHECK (trang_thai IN ('hoat_dong', 'dong_cua'))
);

-- 5. Chỗ đỗ trong bãi
CREATE TABLE cho_do (
  id         SERIAL PRIMARY KEY,
  bai_xe_id  INT NOT NULL REFERENCES bai_xe(id) ON DELETE CASCADE,
  ma_cho     VARCHAR(10) NOT NULL,
  loai_xe    VARCHAR(10) NOT NULL CHECK (loai_xe IN ('xe_may', 'o_to')),
  trang_thai VARCHAR(15) NOT NULL DEFAULT 'trong'
             CHECK (trang_thai IN ('trong', 'da_dat', 'dang_dung', 'bao_tri')),
  UNIQUE (bai_xe_id, ma_cho)
);

-- 6. Bảng giá theo bãi và loại xe
CREATE TABLE bang_gia (
  id              SERIAL PRIMARY KEY,
  bai_xe_id       INT NOT NULL REFERENCES bai_xe(id) ON DELETE CASCADE,
  loai_xe         VARCHAR(10) NOT NULL CHECK (loai_xe IN ('xe_may', 'o_to')),
  gia_theo_gio    NUMERIC(12,2) NOT NULL CHECK (gia_theo_gio >= 0),
  gia_toi_da_ngay NUMERIC(12,2) NOT NULL CHECK (gia_toi_da_ngay >= 0),
  gia_ve_thang    NUMERIC(12,2) NOT NULL CHECK (gia_ve_thang >= 0),
  UNIQUE (bai_xe_id, loai_xe)
);

-- 7. Đặt chỗ trước
CREATE TABLE dat_cho (
  id            SERIAL PRIMARY KEY,
  nguoi_dung_id INT NOT NULL REFERENCES nguoi_dung(id),
  xe_id         INT NOT NULL REFERENCES xe(id),
  cho_do_id     INT NOT NULL REFERENCES cho_do(id),
  bat_dau       TIMESTAMPTZ NOT NULL,
  het_han       TIMESTAMPTZ NOT NULL,
  trang_thai    VARCHAR(15) NOT NULL DEFAULT 'da_dat'
                CHECK (trang_thai IN ('da_dat', 'da_huy', 'het_han', 'hoan_thanh')),
  tao_luc       TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (het_han > bat_dau)
);

-- 8. Lượt gửi xe (vào/ra bãi)
CREATE TABLE luot_gui (
  id            SERIAL PRIMARY KEY,
  xe_id         INT NOT NULL REFERENCES xe(id),
  cho_do_id     INT NOT NULL REFERENCES cho_do(id),
  nhan_vien_id  INT REFERENCES nguoi_dung(id),
  dat_cho_id    INT REFERENCES dat_cho(id),
  gio_vao       TIMESTAMPTZ NOT NULL DEFAULT now(),
  gio_ra        TIMESTAMPTZ,
  so_tien       NUMERIC(12,2) CHECK (so_tien >= 0),
  trang_thai    VARCHAR(10) NOT NULL DEFAULT 'dang_gui'
                CHECK (trang_thai IN ('dang_gui', 'da_ra')),
  CHECK (gio_ra IS NULL OR gio_ra >= gio_vao)
);

-- 9. Vé tháng
CREATE TABLE ve_thang (
  id             SERIAL PRIMARY KEY,
  xe_id          INT NOT NULL REFERENCES xe(id),
  bai_xe_id      INT NOT NULL REFERENCES bai_xe(id),
  ngay_bat_dau   DATE NOT NULL,
  ngay_het_han   DATE NOT NULL,
  gia            NUMERIC(12,2) NOT NULL CHECK (gia >= 0),
  trang_thai     VARCHAR(10) NOT NULL DEFAULT 'hieu_luc'
                 CHECK (trang_thai IN ('hieu_luc', 'het_han', 'da_huy')),
  CHECK (ngay_het_han >= ngay_bat_dau)
);

-- 10. Thanh toán (cho lượt gửi HOẶC vé tháng, đúng một trong hai)
CREATE TABLE thanh_toan (
  id           SERIAL PRIMARY KEY,
  luot_gui_id  INT REFERENCES luot_gui(id),
  ve_thang_id  INT REFERENCES ve_thang(id),
  so_tien      NUMERIC(12,2) NOT NULL CHECK (so_tien > 0),
  phuong_thuc  VARCHAR(15) NOT NULL
               CHECK (phuong_thuc IN ('tien_mat', 'chuyen_khoan', 'vi_dien_tu')),
  tao_luc      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (num_nonnulls(luot_gui_id, ve_thang_id) = 1)
);

-- Chỉ mục để truy vấn nhanh
CREATE INDEX idx_xe_nguoi_dung     ON xe(nguoi_dung_id);
CREATE INDEX idx_cho_do_bai_xe     ON cho_do(bai_xe_id);
CREATE INDEX idx_dat_cho_nguoi_dung ON dat_cho(nguoi_dung_id);
CREATE INDEX idx_luot_gui_xe       ON luot_gui(xe_id);
CREATE INDEX idx_luot_gui_trang_thai ON luot_gui(trang_thai);
CREATE INDEX idx_ve_thang_xe       ON ve_thang(xe_id);

-- Một xe chỉ được có 1 lượt gửi đang diễn ra, một chỗ chỉ có 1 xe đang đỗ
CREATE UNIQUE INDEX uq_luot_gui_xe_dang_gui
  ON luot_gui(xe_id) WHERE trang_thai = 'dang_gui';
CREATE UNIQUE INDEX uq_luot_gui_cho_dang_gui
  ON luot_gui(cho_do_id) WHERE trang_thai = 'dang_gui';
