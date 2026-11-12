package vn.edu.vhu.ltdd.appadminproject;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

public class ParkingMapActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_parking_map);

        // Sau này có thể viết thêm logic gọi API Socket/REST để cập nhật trạng thái ô đỗ real-time tại đây
    }
}