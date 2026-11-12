package vn.edu.vhu.ltdd.appadminproject;

public class VehicleModel {
    private String licensePlate;
    private String vehicleType;
    private String checkInTime;
    private String status;

    public VehicleModel(String licensePlate, String vehicleType, String checkInTime, String status) {
        this.licensePlate = licensePlate;
        this.vehicleType = vehicleType;
        this.checkInTime = checkInTime;
        this.status = status;
    }

    public String getLicensePlate() { return licensePlate; }
    public String getVehicleType() { return vehicleType; }
    public String getCheckInTime() { return checkInTime; }
    public String getStatus() { return status; }
}