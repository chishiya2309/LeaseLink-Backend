package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Notification;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    Page<Notification> findByRecipientIdOrderByCreatedAtDesc(UUID recipientId, Pageable pageable);

    long countByRecipientIdAndIsReadFalse(UUID recipientId);

    Optional<Notification> findByIdAndRecipientId(UUID id, UUID recipientId);

    @Modifying
    @Query("""
            update Notification n
            set n.isRead = true, n.readAt = :readAt
            where n.recipient.id = :recipientId and n.isRead = false
            """)
    int markAllAsRead(@Param("recipientId") UUID recipientId, @Param("readAt") OffsetDateTime readAt);
}
