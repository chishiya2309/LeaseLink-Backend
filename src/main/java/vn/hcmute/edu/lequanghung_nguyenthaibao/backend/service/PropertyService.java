package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.PropertyRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.util.List;
import java.util.UUID;

import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.PropertyStatus;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface PropertyService {
    PropertyResponse createProperty(PropertyRequest request, List<String> imageUrls, String videoUrl, User host);
    PropertyResponse getProperty(UUID id);
    PropertyResponse updateProperty(UUID id, PropertyRequest request, List<String> imageUrls, String videoUrl, User host);
    void deleteProperty(UUID id, User user);
    Page<PropertyResponse> getHostProperties(User host, Pageable pageable);
    Page<PropertyResponse> getPendingProperties(Pageable pageable);
    Page<PropertyResponse> getAllProperties(PropertyStatus status, Pageable pageable);
    PropertyResponse approveProperty(UUID id, User admin);
    PropertyResponse rejectProperty(UUID id, String reason, User admin);
    Page<PropertyResponse> getApprovedProperties(Pageable pageable);
}
