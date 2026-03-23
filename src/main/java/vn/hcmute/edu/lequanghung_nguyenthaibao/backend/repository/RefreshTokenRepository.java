package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.RefreshToken;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
    @Modifying
    @Transactional
    @Query("update RefreshToken r set r.revokedAt = current_timestamp, r.revokeReason = :reason where r.session.id = :sessionId and r.revokedAt is null")
    void revokeBySessionId(UUID sessionId, String reason);

    @Modifying
    @Transactional
    @Query("""
            update RefreshToken r
            set r.revokedAt = current_timestamp, r.revokeReason = :reason
            where r.user = :user and r.revokedAt is null
            """)
    void revokeAllByUser(User user, String reason);
}
