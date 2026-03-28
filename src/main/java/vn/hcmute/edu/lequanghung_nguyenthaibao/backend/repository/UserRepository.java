package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    boolean existsByEmail(String email);
    boolean existsByPhone(String phone);
    Optional<User> findByEmail(String email);

    @Query("""
            SELECT u FROM User u JOIN u.roles r
            WHERE r.code = :roleCode
            AND (:query IS NULL OR :query = ''
                 OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', :query, '%'))
                 OR LOWER(u.email) LIKE LOWER(CONCAT('%', :query, '%'))
                 OR u.phone LIKE CONCAT('%', :query, '%'))
            AND (:status IS NULL OR u.status = :status)
            """)
    Page<User> findAllByRoleCode(
            @Param("roleCode") String roleCode,
            @Param("query") String query,
            @Param("status") UserStatus status,
            Pageable pageable);
}

