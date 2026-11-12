package vn.edu.vhu.ltdd.appadminproject;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class VehicleListActivity extends AppCompatActivity {

    private RecyclerView recyclerView;
    private VehicleAdapter vehicleAdapter;
    private List<VehicleModel> vehicleList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vehicle_list);

        recyclerView = findViewById(R.id.recyclerViewVehicles);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));

        // Khởi tạo dữ liệu mẫu (Sau này sẽ thay bằng dữ liệu gọi API từ Backend Node.js)
        vehicleList = new ArrayList<>();
        vehicleList.add(new VehicleModel("59-C1 888.88", "Xe máy", "07:30 - 12/11/2026", "Đang gửi"));
        vehicleList.add(new VehicleModel("51F 567.89", "Ô tô", "08:15 - 12/11/2026", "Đang gửi"));
        vehicleList.add(new VehicleModel("59-X2 123.45", "Xe máy", "09:00 - 12/11/2026", "Đang gửi"));

        vehicleAdapter = new VehicleAdapter(vehicleList);
        recyclerView.setAdapter(vehicleAdapter);
    }
}