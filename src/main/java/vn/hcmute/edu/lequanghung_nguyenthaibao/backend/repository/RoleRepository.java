package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Role;

import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Short> {
    Optional<Role> findByCode(String code);
}
