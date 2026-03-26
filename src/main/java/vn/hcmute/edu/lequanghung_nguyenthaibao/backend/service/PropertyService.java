package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import org.springframework.web.multipart.MultipartFile;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.PropertyRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;

import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface PropertyService {
    PropertyResponse createProperty(PropertyRequest request, List<MultipartFile> images, MultipartFile video, User host);
    PropertyResponse getProperty(UUID id);
    PropertyResponse updateProperty(UUID id, PropertyRequest request, List<MultipartFile> images, MultipartFile video, User host);
    void softDeleteProperty(UUID id, User host);
    Page<PropertyResponse> getHostProperties(User host, Pageable pageable);
    Page<PropertyResponse> getPendingProperties(Pageable pageable);
    PropertyResponse approveProperty(UUID id, User admin);
    PropertyResponse rejectProperty(UUID id, String reason, User admin);
}
