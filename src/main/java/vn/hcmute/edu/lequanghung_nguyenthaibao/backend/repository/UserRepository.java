package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    boolean existsByEmail(String email);
    boolean existsByPhone(String phone);
    Optional<User> findByEmail(String email);

    @Query("""
            SELECT u FROM User u
            WHERE EXISTS (SELECT 1 FROM User u2 JOIN u2.roles r WHERE u2 = u AND r.code = :roleCode)
            """)
    List<User> findUsersByRoleCode(@Param("roleCode") String roleCode);

    @Query(value = """
            SELECT u FROM User u
            WHERE EXISTS (SELECT 1 FROM User u2 JOIN u2.roles r WHERE u2 = u AND r.code = :roleCode)
            AND (CAST(:query AS string) IS NULL OR CAST(:query AS string) = ''
                 OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', CAST(:query AS string), '%'))
                 OR LOWER(u.email) LIKE LOWER(CONCAT('%', CAST(:query AS string), '%'))
                 OR u.phone LIKE CONCAT('%', CAST(:query AS string), '%'))
            """,
            countQuery = """
            SELECT COUNT(u) FROM User u
            WHERE EXISTS (SELECT 1 FROM User u2 JOIN u2.roles r WHERE u2 = u AND r.code = :roleCode)
            AND (CAST(:query AS string) IS NULL OR CAST(:query AS string) = ''
                 OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', CAST(:query AS string), '%'))
                 OR LOWER(u.email) LIKE LOWER(CONCAT('%', CAST(:query AS string), '%'))
                 OR u.phone LIKE CONCAT('%', CAST(:query AS string), '%'))
            """)
    Page<User> findAllByRoleCode(
            @Param("roleCode") String roleCode,
            @Param("query") String query,
            Pageable pageable);

    @Query(value = """
            SELECT u FROM User u
            WHERE EXISTS (SELECT 1 FROM User u2 JOIN u2.roles r WHERE u2 = u AND r.code = :roleCode)
            AND (CAST(:query AS string) IS NULL OR CAST(:query AS string) = ''
                 OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', CAST(:query AS string), '%'))
                 OR LOWER(u.email) LIKE LOWER(CONCAT('%', CAST(:query AS string), '%'))
                 OR u.phone LIKE CONCAT('%', CAST(:query AS string), '%'))
            AND u.status = :status
            """,
            countQuery = """
            SELECT COUNT(u) FROM User u
            WHERE EXISTS (SELECT 1 FROM User u2 JOIN u2.roles r WHERE u2 = u AND r.code = :roleCode)
            AND (CAST(:query AS string) IS NULL OR CAST(:query AS string) = ''
                 OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', CAST(:query AS string), '%'))
                 OR LOWER(u.email) LIKE LOWER(CONCAT('%', CAST(:query AS string), '%'))
                 OR u.phone LIKE CONCAT('%', CAST(:query AS string), '%'))
            AND u.status = :status
            """)
    Page<User> findAllByRoleCodeAndStatus(
            @Param("roleCode") String roleCode,
            @Param("query") String query,
            @Param("status") UserStatus status,
            Pageable pageable);
}

