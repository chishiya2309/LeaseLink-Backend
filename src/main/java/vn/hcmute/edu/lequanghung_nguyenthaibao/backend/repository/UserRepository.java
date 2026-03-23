package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    boolean existsByEmail(String email);
    boolean existsByPhone(String phone);
}
