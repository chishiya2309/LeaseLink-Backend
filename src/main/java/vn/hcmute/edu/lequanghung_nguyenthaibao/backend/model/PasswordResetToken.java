package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.base.BaseEntity;

import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "password_reset_tokens")
public class PasswordResetToken extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "email_snapshot", nullable = false, length = 255)
    private String emailSnapshot;

    @Column(name = "otp_hash", nullable = false, columnDefinition = "TEXT")
    private String otpHash;

    @Column(name = "reset_token_hash", columnDefinition = "TEXT")
    private String resetTokenHash;

    @Column(name = "expires_at", nullable = false)
    private OffsetDateTime expiresAt;

    @Column(name = "verified_at")
    private OffsetDateTime verifiedAt;

    @Column(name = "consumed_at")
    private OffsetDateTime consumedAt;

    @Column(name = "attempt_count", nullable = false)
    private Integer attemptCount = 0;
}
