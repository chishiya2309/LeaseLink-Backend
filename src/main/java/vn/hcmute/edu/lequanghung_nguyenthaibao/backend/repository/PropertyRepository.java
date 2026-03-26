package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Property;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

@Repository
public interface PropertyRepository extends JpaRepository<Property, UUID>, JpaSpecificationExecutor<Property> {
    Page<Property> findByHost(User host, Pageable pageable);
}
