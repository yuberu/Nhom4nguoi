package vn.edu.vhu.ltdd.appadminproject;

import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
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
        // Thêm sự kiện khi bấm vào item (hoặc một nút xóa bất kỳ trong item)
        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Hộp thoại xác nhận xóa
                new AlertDialog.Builder(v.getContext())
                        .setTitle("Xác nhận xóa")
                        .setMessage("Bạn có chắc chắn muốn xóa nhân viên này không?")
                        .setPositiveButton("Xóa", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                // Xóa item ra khỏi danh sách
                                int currentPosition = holder.getAdapterPosition();
                                if (currentPosition != RecyclerView.NO_POSITION) {
                                    staffList.remove(currentPosition);
                                    notifyItemRemoved(currentPosition);
                                }

                                Toast.makeText(v.getContext(), "Đã xóa thành công!", Toast.LENGTH_SHORT).show();
                            }
                        })
                        .setNegativeButton("Hủy", null)
                        .show();
            }
        });
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