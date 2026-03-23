package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.AuthSession;

import java.util.UUID;

public interface AuthSessionRepository extends JpaRepository<AuthSession, UUID> {
}
