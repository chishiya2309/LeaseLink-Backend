package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Area;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.AreaRepository;

import java.util.List;

@RestController
@RequestMapping("/api/v1/areas")
public class AreaController {
    private final AreaRepository areaRepository;

    public AreaController(AreaRepository areaRepository) {
        this.areaRepository = areaRepository;
    }

    @GetMapping
    public ResponseEntity<List<Area>> getAllAreas() {
        return ResponseEntity.ok(areaRepository.findAll());
    }
}
