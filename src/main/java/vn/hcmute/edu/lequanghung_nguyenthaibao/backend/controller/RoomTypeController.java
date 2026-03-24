package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.RoomType;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RoomTypeRepository;

import java.util.List;

@RestController
@RequestMapping("/api/v1/room-types")
public class RoomTypeController {
    private final RoomTypeRepository roomTypeRepository;

    public RoomTypeController(RoomTypeRepository roomTypeRepository) {
        this.roomTypeRepository = roomTypeRepository;
    }

    @GetMapping
    public ResponseEntity<List<RoomType>> getAllRoomTypes() {
        return ResponseEntity.ok(roomTypeRepository.findAll());
    }
}
