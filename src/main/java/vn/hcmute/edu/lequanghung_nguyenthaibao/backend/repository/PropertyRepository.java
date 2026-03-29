package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Property;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.PropertyStatus;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

@Repository
public interface PropertyRepository extends JpaRepository<Property, UUID>, JpaSpecificationExecutor<Property> {
    Page<Property> findByHost(User host, Pageable pageable);
    Page<Property> findByStatus(PropertyStatus status, Pageable pageable);

    @Modifying
    @Query("UPDATE Property p SET p.status = :newStatus WHERE p.host.id = :ownerId AND p.status = :currentStatus")
    int bulkHideByOwnerId(@Param("ownerId") UUID ownerId,
                           @Param("currentStatus") PropertyStatus currentStatus,
                           @Param("newStatus") PropertyStatus newStatus);
}
