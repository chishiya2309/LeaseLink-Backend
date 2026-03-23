package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.UserService;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @Operation(summary = "Register user for host", description = "Host đăng ký tài khoản mới và ở trạng thái chờ duyệt")
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerUser(@Valid @RequestBody UserRegisterRequest userData) {
        userService.save(userData);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.CREATED.value());
        result.put("message", "Đăng ký thành công! Tài khoản của bạn đang ở trạng thái chờ duyệt.");
        result.put("data", "");

        return new ResponseEntity<>(result, HttpStatus.CREATED);
    }
}
