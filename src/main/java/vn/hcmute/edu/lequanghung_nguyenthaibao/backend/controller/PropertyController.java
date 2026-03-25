package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.PropertyRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.UserRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.PropertyService;

import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

@RestController
@RequestMapping("/api/v1/properties")
@RequiredArgsConstructor
public class PropertyController {

    private final PropertyService propertyService;
    private final UserRepository userRepository;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PropertyResponse> createProperty(
            @Valid @RequestPart("data") PropertyRequest request,
            @RequestPart(value = "images", required = false) List<MultipartFile> images,
            @RequestPart(value = "video", required = false) MultipartFile video) {
        User host = getAuthenticatedUser();
        PropertyResponse response = propertyService.createProperty(request, images, video, host);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PropertyResponse> updateProperty(
            @PathVariable UUID id,
            @Valid @RequestPart("data") PropertyRequest request,
            @RequestPart(value = "images", required = false) List<MultipartFile> images,
            @RequestPart(value = "video", required = false) MultipartFile video) {
        User host = getAuthenticatedUser();
        PropertyResponse response = propertyService.updateProperty(id, request, images, video, host);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProperty(@PathVariable UUID id) {
        User host = getAuthenticatedUser();
        propertyService.softDeleteProperty(id, host);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me")
    public ResponseEntity<Page<PropertyResponse>> getMyProperties(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        User host = getAuthenticatedUser();
        Pageable pageable = PageRequest.of(page, size);
        Page<PropertyResponse> response = propertyService.getHostProperties(host, pageable);
        return ResponseEntity.ok(response);
    }

    private User getAuthenticatedUser() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        User host = null;
        if (principal instanceof UserDetails) {
            String email = ((UserDetails) principal).getUsername();
            host = userRepository.findByEmail(email)
                    .orElseThrow(() -> new IllegalStateException("Authenticated user not found in database"));
        } else if (principal instanceof User) {
            host = (User) principal;
        } else {
            throw new IllegalStateException("Authentication principal is invalid");
        }
        return host;
    }
}
