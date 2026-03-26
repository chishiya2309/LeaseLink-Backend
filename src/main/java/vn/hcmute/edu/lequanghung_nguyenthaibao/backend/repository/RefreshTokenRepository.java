package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.RefreshToken;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
    Optional<RefreshToken> findByJti(UUID jti);

    @Modifying
    @Transactional
    @Query("update RefreshToken r set r.revokedAt = :revokedAt, r.revokeReason = :reason where r.session.id = :sessionId and r.revokedAt is null")
    void revokeBySessionId(@Param("sessionId") UUID sessionId, @Param("reason") String reason, @Param("revokedAt") OffsetDateTime revokedAt);

    @Modifying
    @Transactional
    @Query("""
            update RefreshToken r
            set r.revokedAt = :revokedAt, r.revokeReason = :reason
            where r.user = :user and r.revokedAt is null
            """)
    void revokeAllByUser(@Param("user") User user, @Param("reason") String reason, @Param("revokedAt") OffsetDateTime revokedAt);
}
