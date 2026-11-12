package vn.edu.vhu.ltdd.appadminproject;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class VehicleAdapter extends RecyclerView.Adapter<VehicleAdapter.VehicleViewHolder> {

    private List<VehicleModel> vehicleList;

    public VehicleAdapter(List<VehicleModel> vehicleList) {
        this.vehicleList = vehicleList;
    }

    @NonNull
    @Override
    public VehicleViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_vehicle, parent, false);
        return new VehicleViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull VehicleViewHolder holder, int position) {
        VehicleModel vehicle = vehicleList.get(position);
        holder.txtLicensePlate.setText(vehicle.getLicensePlate());
        holder.txtVehicleType.setText("Loại: " + vehicle.getVehicleType());
        holder.txtCheckInTime.setText("Vào: " + vehicle.getCheckInTime());
        holder.txtStatus.setText(vehicle.getStatus());
    }

    @Override
    public int getItemCount() {
        return vehicleList.size();
    }

    public static class VehicleViewHolder extends RecyclerView.ViewHolder {
        TextView txtLicensePlate, txtVehicleType, txtCheckInTime, txtStatus;

        public VehicleViewHolder(@NonNull View itemView) {
            super(itemView);
            txtLicensePlate = itemView.findViewById(R.id.txtLicensePlate);
            txtVehicleType = itemView.findViewById(R.id.txtVehicleType);
            txtCheckInTime = itemView.findViewById(R.id.txtCheckInTime);
            txtStatus = itemView.findViewById(R.id.txtStatus);
        }
    }
}