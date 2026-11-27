// Các hàm nhỏ dùng chung cho mọi route.

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

// Bọc hàm async để lỗi tự chuyển vào bộ xử lý lỗi chung.
const boc = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

// Lấy id từ đường dẫn, báo 400 nếu không phải số nguyên dương.
function layId(req, ten = 'id') {
  const id = Number(req.params[ten]);
  if (!Number.isInteger(id) || id <= 0) throw new HttpError(400, `${ten} không hợp lệ`);
  return id;
}

function batBuocSoNguyen(giaTri, ten) {
  const n = Number(giaTri);
  if (giaTri === undefined || giaTri === null || giaTri === '' || !Number.isInteger(n) || n <= 0) {
    throw new HttpError(400, `${ten} phải là số nguyên dương`);
  }
  return n;
}

function batBuocChuoi(giaTri, ten, min = 1, max = 200) {
  if (typeof giaTri !== 'string' || giaTri.trim().length < min || giaTri.trim().length > max) {
    throw new HttpError(400, `${ten} phải có từ ${min} đến ${max} ký tự`);
  }
  return giaTri.trim();
}

function batBuocSoKhongAm(giaTri, ten) {
  const n = Number(giaTri);
  if (giaTri === undefined || giaTri === null || giaTri === '' || !Number.isFinite(n) || n < 0) {
    throw new HttpError(400, `${ten} phải là số không âm`);
  }
  return n;
}

function batBuocThoiGian(giaTri, ten) {
  const d = new Date(giaTri);
  if (!giaTri || Number.isNaN(d.getTime())) throw new HttpError(400, `${ten} không phải thời gian hợp lệ`);
  return d;
}

function batBuocTrongDanhSach(giaTri, danhSach, ten) {
  if (!danhSach.includes(giaTri)) throw new HttpError(400, `${ten} chỉ nhận: ${danhSach.join(', ')}`);
  return giaTri;
}

const LOAI_XE = ['xe_may', 'o_to'];

module.exports = {
  HttpError, boc, layId, LOAI_XE,
  batBuocSoNguyen, batBuocChuoi, batBuocSoKhongAm, batBuocThoiGian, batBuocTrongDanhSach,
};
