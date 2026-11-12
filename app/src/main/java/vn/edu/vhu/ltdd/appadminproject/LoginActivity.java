package vn.edu.vhu.ltdd.appadminproject;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class LoginActivity extends AppCompatActivity {

    private EditText edtUsername, edtPassword;
    private Button btnLogin;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        // Ánh xạ thành phần giao diện
        edtUsername = findViewById(R.id.edtUsername);
        edtPassword = findViewById(R.id.edtPassword);
        btnLogin = findViewById(R.id.btnLogin);

        // Bắt sự kiện bấm nút đăng nhập
        btnLogin.setOnClickListener(v -> handleLogin());
    }

    private void handleLogin() {
        String username = edtUsername.getText().toString().trim();
        String password = edtPassword.getText().toString().trim();

        // Kiểm tra validation cơ bản
        if (username.isEmpty()) {
            edtUsername.setError("Vui lòng nhập tên tài khoản!");
            edtUsername.requestFocus();
            return;
        }

        if (password.isEmpty()) {
            edtPassword.setError("Vui lòng nhập mật khẩu!");
            edtPassword.requestFocus();
            return;
        }

        // Phân quyền đăng nhập
        if (username.equals("admin") && password.equals("123456")) {
            Toast.makeText(this, "Đăng nhập Admin thành công!", Toast.LENGTH_SHORT).show();
            Intent intent = new Intent(LoginActivity.this, MainActivity.class);
            intent.putExtra("USER_ROLE", "ADMIN");
            startActivity(intent);
            finish();
        } else {
            Toast.makeText(this, "Đăng nhập Nhân viên thành công!", Toast.LENGTH_SHORT).show();
            Intent intent = new Intent(LoginActivity.this, StaffListActivity.class);
            intent.putExtra("USER_ROLE", "STAFF");
            startActivity(intent);
            finish();
        }
    }}