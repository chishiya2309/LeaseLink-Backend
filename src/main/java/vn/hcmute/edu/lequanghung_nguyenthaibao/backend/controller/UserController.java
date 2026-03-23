package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/users")
public class UserController {

    @Operation(summary = "Register user for host", description = "Host đăng ký tài khoản mới và ở trạng thái chờ duyệt")
    @PostMapping("/register")
    public Map<String, Object> registerUser(@RequestBody UserRegisterRequest userData) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.CREATED.value());
        result.put("message", "User registered successfully");
        result.put("data", 3);

        return result;
    }
}
