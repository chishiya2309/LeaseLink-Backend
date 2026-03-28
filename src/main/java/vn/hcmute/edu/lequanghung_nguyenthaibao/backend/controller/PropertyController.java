package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.security.access.prepost.PreAuthorize;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.PropertyPageResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.PropertyRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.RejectionRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.SearchPropertyRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.UserRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.PropertyService;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.PropertyMediaService;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.PropertyStatus;

@RestController
@RequestMapping("/api/v1/properties")
@RequiredArgsConstructor
@Slf4j(topic = "PROPERTY-CONTROLLER")
public class PropertyController {

    private final PropertyService propertyService;
    private final PropertyMediaService propertyMediaService;
    private final UserRepository userRepository;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PropertyResponse> createProperty(
            @Valid @RequestPart("data") PropertyRequest request,
            @RequestPart(value = "images", required = false) List<MultipartFile> images,
            @RequestPart(value = "video", required = false) MultipartFile video) {
        User host = getAuthenticatedUser();
        
        // 1. Upload media outside transaction
        List<String> imageUrls = propertyMediaService.uploadImages(images);
        String videoUrl = propertyMediaService.uploadVideo(video);
        
        // 2. Persist to DB
        PropertyResponse response = propertyService.createProperty(request, imageUrls, videoUrl, host);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PropertyResponse> updateProperty(
            @PathVariable UUID id,
            @Valid @RequestPart("data") PropertyRequest request,
            @RequestPart(value = "images", required = false) List<MultipartFile> images,
            @RequestPart(value = "video", required = false) MultipartFile video) {
        User host = getAuthenticatedUser();

        // 1. Upload new media if provided
        List<String> imageUrls = (images != null && !images.isEmpty()) ? propertyMediaService.uploadImages(images) : null;
        String videoUrl = (video != null && !video.isEmpty()) ? propertyMediaService.uploadVideo(video) : null;

        // 2. Persist update
        PropertyResponse response = propertyService.updateProperty(id, request, imageUrls, videoUrl, host);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProperty(@PathVariable UUID id) {
        User user = getAuthenticatedUser();
        
        // 1. Get current property to find media URLs for deletion
        PropertyResponse property = propertyService.getProperty(id);
        
        // 2. Delete from DB first (if rollback needed, we still have URLs, but S3 delete is hard to rollback)
        // Actually, best practice is DB delete first, then S3 (orphaned files are okay, missing files aren't)
        propertyService.deleteProperty(id, user);
        
        // 3. Delete from S3
        if (property.getImages() != null) {
            List<String> urls = property.getImages().stream().map(PropertyResponse.ImageResponse::getImageUrl).toList();
            propertyMediaService.deleteMedias(urls);
        }
        
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

    @GetMapping("/pending")
    public ResponseEntity<Page<PropertyResponse>> getPendingProperties(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<PropertyResponse> response = propertyService.getPendingProperties(pageable);
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Tìm kiếm bất động sản", description = "Cho phép tìm kiếm bất động sản theo bộ lọc")
    @GetMapping("/search")
    public Map<String, Object> searchProperties(
            SearchPropertyRequest req,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "8") int size) {

        log.info("Search properties with filters: {}", req);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("status", HttpStatus.OK.value());
        result.put("message", "Search properties with filters");
        result.put("data", propertyService.searchProperties(req, page, size));

        return result;
    }

    @GetMapping("/approved")
    public ResponseEntity<Page<PropertyResponse>> getApprovedProperties(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        // Sort by createdAt DESC to show newest first
        Pageable pageable = PageRequest.of(page, size, org.springframework.data.domain.Sort.by("createdAt").descending());
        Page<PropertyResponse> response = propertyService.getApprovedProperties(pageable);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<PropertyResponse>> getAllProperties(
            @RequestParam(required = false) PropertyStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<PropertyResponse> response = propertyService.getAllProperties(status, pageable);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/approve")
    public ResponseEntity<PropertyResponse> approveProperty(@PathVariable UUID id) {
        User admin = getAuthenticatedUser();
        PropertyResponse response = propertyService.approveProperty(id, admin);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<PropertyResponse> rejectProperty(
            @PathVariable UUID id,
            @RequestBody RejectionRequest rejectionRequest) {
        User admin = getAuthenticatedUser();
        PropertyResponse response = propertyService.rejectProperty(id, rejectionRequest.getReason(), admin);
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
