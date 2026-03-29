package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response;

import lombok.Getter;
import lombok.Setter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.NotificationType;

import java.io.Serial;
import java.io.Serializable;
import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Setter
public class NotificationResponse implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;

    private UUID id;
    private NotificationType type;
    private String title;
    private String message;
    private String link;
    private Boolean isRead;
    private OffsetDateTime createdAt;
    private OffsetDateTime readAt;
}
