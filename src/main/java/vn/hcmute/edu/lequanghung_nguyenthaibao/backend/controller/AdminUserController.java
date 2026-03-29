package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.AdminCreateHostRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ToggleUserStatusRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.AdminUserResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.UserService;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@Slf4j(topic = "ADMIN-USER-CTRL")
@Tag(name = "Admin - User Management", description = "APIs quản lý người dùng dành cho Admin")
public class AdminUserController {

    private final UserService userService;

    @Operation(summary = "Lấy danh sách Host", description = "Admin xem toàn bộ danh sách Host với khả năng tìm kiếm và lọc theo trạng thái")
    @GetMapping("/hosts")
    public ResponseEntity<Map<String, Object>> getHosts(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) UserStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size) {

        log.info("Lấy danh sách Host");

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<AdminUserResponse> result = userService.adminFindAllHosts(query, status, pageable);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", HttpStatus.OK.value());
        response.put("message", "Lấy danh sách Host thành công.");
        response.put("data", result);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Tạo Host mới", description = "Admin tạo tài khoản Host mới. Hệ thống tự sinh mật khẩu và gửi email thông báo.")
    @PostMapping("/hosts")
    public ResponseEntity<Map<String, Object>> createHost(
            @Valid @RequestBody AdminCreateHostRequest request) {

        UUID newHostId = userService.adminCreateHost(request);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", HttpStatus.CREATED.value());
        response.put("message", "Tạo tài khoản Host thành công. Thông tin đăng nhập đã được gửi đến email của Host.");
        response.put("data", Map.of("hostId", newHostId));
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "Khóa / Mở khóa tài khoản Host", description = "Admin thay đổi trạng thái tài khoản (ACTIVE / LOCKED). Khi khóa: thu hồi session + ẩn toàn bộ tin đăng.")
    @PatchMapping("/hosts/{id}/status")
    public ResponseEntity<Map<String, Object>> toggleHostStatus(
            @PathVariable UUID id,
            @Valid @RequestBody ToggleUserStatusRequest request,
            @AuthenticationPrincipal UUID currentAdminId) {

        AdminUserResponse updated = userService.adminToggleUserStatus(id, request.getStatus(), request.getReason(), currentAdminId);

        String msg = request.getStatus() == UserStatus.LOCKED
                ? "Tài khoản Host đã bị khóa. Toàn bộ tin đăng đã được ẩn."
                : "Tài khoản Host đã được mở khóa thành công.";

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", HttpStatus.OK.value());
        response.put("message", msg);
        response.put("data", updated);
        return ResponseEntity.ok(response);
    }
}
