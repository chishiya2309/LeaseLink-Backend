package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.NotificationResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Notification;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Property;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.NotificationType;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.NotificationRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.UserRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.NotificationService;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j(topic = "NOTIFICATION-SERVICE")
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<NotificationResponse> getMyNotifications(UUID userId, Pageable pageable) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId, pageable)
                .map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public long countUnread(UUID userId) {
        return notificationRepository.countByRecipientIdAndIsReadFalse(userId);
    }

    @Override
    @Transactional
    public NotificationResponse markAsRead(UUID userId, UUID notificationId) {
        Notification notification = notificationRepository.findByIdAndRecipientId(notificationId, userId)
                .orElseThrow(() -> new IllegalArgumentException("Notification not found"));

        if (!Boolean.TRUE.equals(notification.getIsRead())) {
            notification.setIsRead(true);
            notification.setReadAt(OffsetDateTime.now());
            notificationRepository.save(notification);
        }

        return mapToResponse(notification);
    }

    @Override
    @Transactional
    public void markAllAsRead(UUID userId) {
        notificationRepository.markAllAsRead(userId, OffsetDateTime.now());
    }

    @Override
    @Transactional
    public void notifyAdminsNewHostRegistration(User host) {
        List<User> admins = userRepository.findUsersByRoleCode("ADMIN");
        if (admins.isEmpty()) {
            return;
        }

        List<Notification> notifications = admins.stream()
                .map(admin -> buildNotification(
                        admin,
                        NotificationType.NEW_HOST_REGISTRATION,
                        "Có host mới đăng ký",
                        "Host " + host.getFullName() + " vừa đăng ký tài khoản và đang chờ duyệt.",
                        "/dashboard?page=quan-ly-host"
                ))
                .toList();

        notificationRepository.saveAll(notifications);
        log.info("Created {} admin notifications for new host registration {}", notifications.size(), host.getId());
    }

    @Override
    @Transactional
    public void notifyAdminsNewProperty(Property property) {
        List<User> admins = userRepository.findUsersByRoleCode("ADMIN");
        if (admins.isEmpty()) {
            return;
        }

        String hostName = property.getHost() != null ? property.getHost().getFullName() : "Host";
        String propertyTitle = property.getTitle() != null ? property.getTitle() : "Tin đăng mới";

        List<Notification> notifications = admins.stream()
                .map(admin -> buildNotification(
                        admin,
                        NotificationType.NEW_PROPERTY_SUBMISSION,
                        "Có bài đăng mới chờ duyệt",
                        hostName + " vừa gửi bài đăng \"" + propertyTitle + "\" để admin kiểm duyệt.",
                        "/dashboard?page=duyet-tin-dang"
                ))
                .toList();

        notificationRepository.saveAll(notifications);
        log.info("Created {} admin notifications for property {}", notifications.size(), property.getId());
    }

    @Override
    @Transactional
    public void notifyHostPropertyApproved(Property property) {
        if (property.getHost() == null) {
            return;
        }

        Notification notification = buildNotification(
                property.getHost(),
                NotificationType.PROPERTY_APPROVED,
                "Tin đăng đã được duyệt",
                "Bài đăng \"" + property.getTitle() + "\" của bạn đã được admin duyệt thành công.",
                "/dashboard?page=tin-dang-cua-toi"
        );

        notificationRepository.save(notification);
    }

    @Override
    @Transactional
    public void notifyHostPropertyRejected(Property property) {
        if (property.getHost() == null) {
            return;
        }

        String reason = property.getRejectedReason();
        String message = "Bài đăng \"" + property.getTitle() + "\" của bạn đã bị từ chối.";
        if (reason != null && !reason.isBlank()) {
            message += " Lý do: " + reason;
        }

        Notification notification = buildNotification(
                property.getHost(),
                NotificationType.PROPERTY_REJECTED,
                "Tin đăng bị từ chối",
                message,
                "/dashboard?page=tin-dang-cua-toi"
        );

        notificationRepository.save(notification);
    }

    private Notification buildNotification(User recipient, NotificationType type, String title, String message, String link) {
        Notification notification = new Notification();
        notification.setRecipient(recipient);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setLink(link);
        notification.setIsRead(false);
        return notification;
    }

    private NotificationResponse mapToResponse(Notification notification) {
        NotificationResponse response = new NotificationResponse();
        response.setId(notification.getId());
        response.setType(notification.getType());
        response.setTitle(notification.getTitle());
        response.setMessage(notification.getMessage());
        response.setLink(notification.getLink());
        response.setIsRead(notification.getIsRead());
        response.setCreatedAt(notification.getCreatedAt());
        response.setReadAt(notification.getReadAt());
        return response;
    }
}
