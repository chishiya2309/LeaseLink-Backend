package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.PasswordResetToken;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, UUID> {

    Optional<PasswordResetToken> findFirstByUserAndConsumedAtIsNullOrderByCreatedAtDesc(User user);

    Optional<PasswordResetToken> findFirstByUserAndConsumedAtIsNullAndVerifiedAtIsNotNullOrderByVerifiedAtDesc(User user);

    @Modifying
    @Query("""
            update PasswordResetToken p
            set p.consumedAt = :consumedAt
            where p.user = :user and p.consumedAt is null
            """)
    void consumeAllActiveByUser(User user, OffsetDateTime consumedAt);
}
