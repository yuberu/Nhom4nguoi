package vn.edu.vhu.ltdd.appadminproject;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class StaffAdapter extends RecyclerView.Adapter<StaffAdapter.StaffViewHolder> {

    private List<StaffModel> staffList;

    public StaffAdapter(List<StaffModel> staffList) {
        this.staffList = staffList;
    }

    @NonNull
    @Override
    public StaffViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_staff, parent, false);
        return new StaffViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull StaffViewHolder holder, int position) {
        StaffModel staff = staffList.get(position);
        holder.txtName.setText(staff.getName());
        holder.txtShift.setText(staff.getShift());
        holder.txtStatus.setText(staff.getStatus());
    }

    @Override
    public int getItemCount() {
        return staffList.size();
    }

    public static class StaffViewHolder extends RecyclerView.ViewHolder {
        TextView txtName, txtShift, txtStatus;

        public StaffViewHolder(@NonNull View itemView) {
            super(itemView);
            txtName = itemView.findViewById(R.id.txtStaffName);
            txtShift = itemView.findViewById(R.id.txtStaffRole);
            txtStatus = itemView.findViewById(R.id.txtStaffStatus);
        }
    }
}