package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.NotificationResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Property;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.util.UUID;

public interface NotificationService {
    Page<NotificationResponse> getMyNotifications(UUID userId, Pageable pageable);

    long countUnread(UUID userId);

    NotificationResponse markAsRead(UUID userId, UUID notificationId);

    void markAllAsRead(UUID userId);

    void notifyAdminsNewHostRegistration(User host);

    void notifyAdminsNewProperty(Property property);

    void notifyHostPropertyApproved(Property property);

    void notifyHostPropertyRejected(Property property);
}
