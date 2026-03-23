package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.AuthSession;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.util.UUID;

public interface AuthSessionRepository extends JpaRepository<AuthSession, UUID> {
    @Modifying
    @Query("""
            update AuthSession a
            set a.isActive = false
            where a.user = :user and a.isActive = true
            """)
    void deactivateAllByUser(User user);
}
