package vn.edu.vhu.ltdd.appadminproject;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private TextView txtWelcome;
    private Button btnParkingMap, btnVehicleList, btnStaff, btnReport, btnLogout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Ánh xạ các thành phần
        txtWelcome = findViewById(R.id.txtWelcome);
        btnParkingMap = findViewById(R.id.btnParkingMap);
        btnVehicleList = findViewById(R.id.btnVehicleList);
        btnStaff = findViewById(R.id.btnStaff);
        btnReport = findViewById(R.id.btnReport);
        btnLogout = findViewById(R.id.btnLogout);

        // Nhận dữ liệu vai trò truyền sang từ LoginActivity
        String role = getIntent().getStringExtra("USER_ROLE");
        if (role != null) {
            txtWelcome.setText("Xin chào: " + role);
        }

        // Xử lý sự kiện bấm các nút chức năng quản lý bãi xe
        btnParkingMap.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, ParkingMapActivity.class);
            startActivity(intent);
        });

        btnVehicleList.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, VehicleListActivity.class);
            startActivity(intent);
        });

        btnStaff.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, StaffListActivity.class);
            startActivity(intent);
        });

        btnReport.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, ReportActivity.class);
            startActivity(intent);
        });

        // Xử lý đăng xuất quay lại màn hình Login
        btnLogout.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, LoginActivity.class);
            startActivity(intent);
            finish();
        });
    }
}