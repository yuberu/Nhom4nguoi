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

        // Tạm thời giả lập xác thực phân quyền chuẩn bị cho kết nối API Backend
        if (username.equals("admin") && password.equals("123456")) {
            Toast.makeText(this, "Đăng nhập thành công với quyền Admin!", Toast.LENGTH_SHORT).show();

            // Chuyển sang màn hình Dashboard chính
            Intent intent = new Intent(LoginActivity.this, MainActivity.class);
            intent.putExtra("USER_ROLE", "ADMIN");
            startActivity(intent);
            finish(); // Đóng LoginActivity để không quay lại được bằng nút Back
        } else {
            Toast.makeText(this, "Tài khoản hoặc mật khẩu không chính xác!", Toast.LENGTH_SHORT).show();
        }
    }
}