package vn.edu.vhu.ltdd.appadminproject;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class StaffListActivity extends AppCompatActivity {

    private RecyclerView recyclerView;
    private StaffAdapter staffAdapter;
    private List<StaffModel> staffList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_staff_list);

        recyclerView = findViewById(R.id.recyclerViewStaff);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));

        staffList = new ArrayList<>();
        staffList.add(new StaffModel("Bùi Quang Long", "Ca Sáng (06:00 - 14:00)", "Đang trực"));
        staffList.add(new StaffModel("Nguyễn Quốc Long", "Ca Chiều (14:00 - 22:00)", "Sắp vào ca"));
        staffList.add(new StaffModel("Tô Nhật Duy", "Ca Đêm (22:00 - 06:00)", "Nghỉ"));

        staffAdapter = new StaffAdapter(staffList);
        recyclerView.setAdapter(staffAdapter);
    }
}