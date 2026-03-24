package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Property;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.PropertyImage;

import java.util.List;
import java.util.UUID;

@Repository
public interface PropertyImageRepository extends JpaRepository<PropertyImage, UUID> {
    List<PropertyImage> findByProperty(Property property);
    void deleteByProperty(Property property);
}
