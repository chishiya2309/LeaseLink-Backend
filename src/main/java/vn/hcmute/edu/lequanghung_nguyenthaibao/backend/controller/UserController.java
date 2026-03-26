package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import io.swagger.v3.oas.annotations.Operation;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ForgotPasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ResetPasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserLoginRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.VerifyResetCodeRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.LoginResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.ResetPasswordVerifyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.UserService;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

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

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> loginUser(
            @Valid @RequestBody UserLoginRequest request,
            HttpServletRequest httpRequest) {
        LoginResponse loginResponse = userService.login(request, httpRequest);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Đăng nhập thành công!");
        result.put("data", loginResponse);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<Map<String, Object>> refreshToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        LoginResponse loginResponse = userService.refreshToken(refreshToken);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Làm mới token thành công!");
        result.put("data", loginResponse);

        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        userService.forgotPassword(request);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi mã xác thực.");
        result.put("data", "");
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @PostMapping("/verify-reset-code")
    public ResponseEntity<Map<String, Object>> verifyResetCode(@Valid @RequestBody VerifyResetCodeRequest request) {
        ResetPasswordVerifyResponse response = userService.verifyResetCode(request);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Xác thực mã thành công.");
        result.put("data", response);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, Object>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Đặt lại mật khẩu thành công.");
        result.put("data", "");
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @PostMapping("/logout")
    public ResponseEntity<Map<String, Object>> logoutUser(
            @RequestHeader("X-JTI") String jti,
            @RequestHeader("X-SID") String sid,
            @AuthenticationPrincipal UUID userId) {
        userService.logout(jti, UUID.fromString(sid), userId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Đăng xuất thành công!");
        return new ResponseEntity<>(result, HttpStatus.OK);
    }
}
