// Tính tiền gửi xe. Hàm thuần (không đụng database) nên dễ kiểm tra và dễ đổi luật.
//  - Làm tròn LÊN theo giờ, tối thiểu 1 giờ.
//  - Mỗi 24 giờ tính theo mức giá tối đa của ngày.
//  - Phần giờ lẻ còn lại: giá theo giờ nhưng không vượt mức tối đa của ngày.
function tinhTien({ gioVao, gioRa, giaTheoGio, giaToiDaNgay }) {
  const phut = Math.max(0, (new Date(gioRa) - new Date(gioVao)) / 60000);
  const soGio = Math.max(1, Math.ceil(phut / 60));
  const soNgay = Math.floor(soGio / 24);
  const gioLe = soGio - soNgay * 24;
  const soTien = soNgay * giaToiDaNgay + Math.min(gioLe * giaTheoGio, giaToiDaNgay);
  return { soGio, soTien };
}

module.exports = { tinhTien };
