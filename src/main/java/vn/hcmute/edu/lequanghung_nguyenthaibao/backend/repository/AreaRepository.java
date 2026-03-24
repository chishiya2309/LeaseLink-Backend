package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Area;

@Repository
public interface AreaRepository extends JpaRepository<Area, Long> {
}
