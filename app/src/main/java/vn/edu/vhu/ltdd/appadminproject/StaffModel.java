package vn.edu.vhu.ltdd.appadminproject;

public class StaffModel {
    private String name;
    private String shift;
    private String status;

    // 1. Constructor rỗng (Rất quan trọng khi dùng Gson / Retrofit để parse dữ liệu từ API)
    public StaffModel() {
    }

    // 2. Constructor đầy đủ tham số
    public StaffModel(String name, String shift, String status) {
        this.name = name;
        this.shift = shift;
        this.status = status;
    }

    // Các Getters (Lấy dữ liệu)
    public String getName() { return name; }
    public String getShift() { return shift; }
    public String getStatus() { return status; }

    // Các Setters (Gán/Cập nhật dữ liệu - thêm vào để tránh lỗi khi binding dữ liệu động)
    public void setName(String name) { this.name = name; }
    public void setShift(String shift) { this.shift = shift; }
    public void setStatus(String status) { this.status = status; }
}