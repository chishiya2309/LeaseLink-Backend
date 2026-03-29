package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.NotificationResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.UserRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.NotificationService;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final UserRepository userRepository;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getMyNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        UUID currentUserId = getAuthenticatedUserId();
        Pageable pageable = PageRequest.of(page, size);
        Page<NotificationResponse> notifications = notificationService.getMyNotifications(currentUserId, pageable);
        long unreadCount = notificationService.countUnread(currentUserId);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Lấy danh sách thông báo thành công.");
        result.put("data", Map.of(
                "content", notifications.getContent(),
                "page", notifications.getNumber(),
                "size", notifications.getSize(),
                "totalElements", notifications.getTotalElements(),
                "totalPages", notifications.getTotalPages(),
                "unreadCount", unreadCount
        ));
        return ResponseEntity.ok(result);
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Map<String, Object>> markAsRead(
            @PathVariable UUID id) {
        UUID currentUserId = getAuthenticatedUserId();
        NotificationResponse notification = notificationService.markAsRead(currentUserId, id);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Đã đánh dấu thông báo là đã đọc.");
        result.put("data", notification);
        return ResponseEntity.ok(result);
    }

    @PatchMapping("/read-all")
    public ResponseEntity<Map<String, Object>> markAllAsRead() {
        UUID currentUserId = getAuthenticatedUserId();
        notificationService.markAllAsRead(currentUserId);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Đã đánh dấu toàn bộ thông báo là đã đọc.");
        result.put("data", "");
        return ResponseEntity.ok(result);
    }

    private UUID getAuthenticatedUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        User user = null;

        if (principal instanceof UserDetails userDetails) {
            user = userRepository.findByEmail(userDetails.getUsername())
                    .orElseThrow(() -> new IllegalStateException("Authenticated user not found in database"));
        } else if (principal instanceof User authenticatedUser) {
            user = authenticatedUser;
        }

        if (user == null) {
            throw new IllegalStateException("Authentication principal is invalid");
        }

        return user.getId();
    }
}
