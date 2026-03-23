package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.RevokedJti;

import java.util.UUID;

public interface RevokedJtiRepository extends JpaRepository<RevokedJti, UUID> {
}
