package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.PropertyPageResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.PropertyRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.SearchPropertyRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.*;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.PropertyStatus;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.AreaRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.PropertyRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.PropertySpecification;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RoomTypeRepository;
import org.springframework.data.jpa.domain.Specification;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.PropertyService;

@Service
@RequiredArgsConstructor
@Slf4j
public class PropertyServiceImpl implements PropertyService {

    private final PropertyRepository propertyRepository;
    private final AreaRepository areaRepository;
    private final RoomTypeRepository roomTypeRepository;

    @Override
    @Transactional
    public PropertyResponse createProperty(PropertyRequest request, List<String> imageUrls, String videoUrl, User host) {
        Area area = areaRepository.findById(request.getAreaId())
                .orElseThrow(() -> new IllegalArgumentException("Area not found with id: " + request.getAreaId()));
        RoomType roomType = roomTypeRepository.findById(request.getRoomTypeId())
                .orElseThrow(() -> new IllegalArgumentException("RoomType not found with id: " + request.getRoomTypeId()));

        Property property = new Property();
        property.setHost(host);
        property.setArea(area);
        property.setRoomType(roomType);
        property.setTitle(request.getTitle());
        property.setDescription(request.getDescription());
        property.setAddressLine(request.getAddressLine());
        property.setMonthlyPrice(request.getMonthlyPrice());
        property.setAreaM2(request.getAreaM2());
        property.setBedrooms(request.getBedrooms());
        property.setAllowPets(request.getAllowPets());
        property.setStatus(PropertyStatus.PENDING);

        if (videoUrl != null) {
            PropertyImage videoImage = new PropertyImage();
            videoImage.setImageUrl(videoUrl);
            videoImage.setSortOrder(999);
            videoImage.setIsThumbnail(false);
            property.addImage(videoImage);
        }

        if (imageUrls != null) {
            for (int i = 0; i < imageUrls.size(); i++) {
                PropertyImage propertyImage = new PropertyImage();
                propertyImage.setImageUrl(imageUrls.get(i));
                propertyImage.setSortOrder(i);
                propertyImage.setIsThumbnail(i == 0);
                property.addImage(propertyImage);
            }
        }

        return mapToResponse(propertyRepository.save(property));
    }

    @Override
    @Transactional
    public PropertyResponse updateProperty(UUID id, PropertyRequest request, List<String> imageUrls, String videoUrl, User host) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));

        boolean isAdmin = userHasRole(host, "ADMIN");
        if (!isAdmin && !property.getHost().getId().equals(host.getId())) {
            throw new IllegalArgumentException("You are not authorized to update this property.");
        }

        Area area = areaRepository.findById(request.getAreaId())
                .orElseThrow(() -> new IllegalArgumentException("Area not found"));
        RoomType roomType = roomTypeRepository.findById(request.getRoomTypeId())
                .orElseThrow(() -> new IllegalArgumentException("RoomType not found"));

        property.setArea(area);
        property.setRoomType(roomType);
        property.setTitle(request.getTitle());
        property.setDescription(request.getDescription());
        property.setAddressLine(request.getAddressLine());
        property.setMonthlyPrice(request.getMonthlyPrice());
        property.setAreaM2(request.getAreaM2());
        property.setBedrooms(request.getBedrooms());
        property.setAllowPets(request.getAllowPets());
        property.setStatus(PropertyStatus.PENDING);

        // Update video if provided
        if (videoUrl != null) {
            if (property.getImages() != null) {
                property.getImages().removeIf(img -> {
                    String url = img.getImageUrl().toLowerCase();
                    return url.endsWith(".mp4") || url.endsWith(".mov") || url.endsWith(".webm");
                });
            }
            PropertyImage videoImage = new PropertyImage();
            videoImage.setImageUrl(videoUrl);
            videoImage.setSortOrder(999);
            videoImage.setIsThumbnail(false);
            property.addImage(videoImage);
        }

        // Update images if provided
        if (imageUrls != null && !imageUrls.isEmpty()) {
            if (property.getImages() != null) {
                property.getImages().clear();
            }

            for (int i = 0; i < imageUrls.size(); i++) {
                PropertyImage propertyImage = new PropertyImage();
                propertyImage.setImageUrl(imageUrls.get(i));
                propertyImage.setSortOrder(i);
                propertyImage.setIsThumbnail(i == 0);
                property.addImage(propertyImage);
            }
        }

        return mapToResponse(propertyRepository.save(property));
    }

    @Override
    @Transactional
    public void deleteProperty(UUID id, User user) {
        log.info("Deleting property: {}", id);
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));

        boolean isAdmin = userHasRole(user, "ADMIN");
        if (!isAdmin && !property.getHost().getId().equals(user.getId())) {
            throw new IllegalArgumentException("You are not authorized to delete this property.");
        }

        property.setStatus(PropertyStatus.DELETED);
        propertyRepository.save(property);
        log.info("Deleted property: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PropertyResponse> getHostProperties(User host, Pageable pageable) {
        return propertyRepository.findByHost(host, pageable).map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PropertyResponse> getPendingProperties(Pageable pageable) {
        return propertyRepository.findByStatus(PropertyStatus.PENDING, pageable).map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PropertyResponse> getAllProperties(PropertyStatus status, Pageable pageable) {
        if (status != null) {
            return propertyRepository.findByStatus(status, pageable).map(this::mapToResponse);
        }
        return propertyRepository.findAll(pageable).map(this::mapToResponse);
    }

    @Override
    @Transactional
    public PropertyResponse approveProperty(UUID id, User admin) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        property.setStatus(PropertyStatus.APPROVED);
        property.setApprovedBy(admin);
        property.setApprovedAt(java.time.OffsetDateTime.now());
        return mapToResponse(propertyRepository.save(property));
    }

    @Override
    @Transactional
    public PropertyResponse rejectProperty(UUID id, String reason, User admin) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        property.setStatus(PropertyStatus.REJECTED);
        property.setRejectedReason(reason);
        return mapToResponse(propertyRepository.save(property));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PropertyResponse> getApprovedProperties(Pageable pageable) {
        return propertyRepository.findByStatus(PropertyStatus.APPROVED, pageable).map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public PropertyPageResponse searchProperties(SearchPropertyRequest request,
                                                 int page, int size) {
        log.info("Searching properties with criteria: {}", request);

        Sort.Order order = new Sort.Order(Sort.Direction.DESC, "createdAt");

        int pageNo = 0;
        if (page > 0) {
            pageNo = page - 1;
        }

        Pageable pageable = PageRequest.of(pageNo, size, Sort.by(order));
        Page<Property> entityPage;

        Specification<Property> spec = PropertySpecification.buildBasicSearchSpecification(request);
        entityPage = propertyRepository.findAll(spec, pageable);

        PropertyPageResponse response = new PropertyPageResponse();
        response.setProperties(entityPage.getContent().stream().map(this::mapToResponse).toList());
        response.setPageNumber(entityPage.getNumber());
        response.setPageSize(entityPage.getSize());
        response.setTotalPages(entityPage.getTotalPages());
        response.setTotalElements(entityPage.getTotalElements());
        return response;
    }

    @Override
    @Transactional(readOnly = true)
    public PropertyResponse getProperty(UUID id) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        return mapToResponse(property);
    }

    private boolean userHasRole(User user, String roleCode) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream()
                .anyMatch(role -> roleCode.equals(role.getCode()));
    }

    private PropertyResponse mapToResponse(Property property) {
        PropertyResponse response = new PropertyResponse();
        response.setId(property.getId());
        if (property.getHost() != null) {
            response.setHostId(property.getHost().getId());
            response.setHostName(property.getHost().getEmail());
        }
        if (property.getArea() != null) {
            response.setAreaId(property.getArea().getId());
            response.setAreaName(property.getArea().getName());
        }
        if (property.getRoomType() != null) {
            response.setRoomTypeId(property.getRoomType().getId());
            response.setRoomTypeName(property.getRoomType().getName());
        }
        response.setTitle(property.getTitle());
        response.setDescription(property.getDescription());
        response.setAddressLine(property.getAddressLine());
        response.setMonthlyPrice(property.getMonthlyPrice());
        response.setAreaM2(property.getAreaM2());
        response.setBedrooms(property.getBedrooms());
        response.setAllowPets(property.getAllowPets());
        response.setStatus(property.getStatus());
        response.setCreatedAt(property.getCreatedAt());
        response.setRejectedReason(property.getRejectedReason());

        if (property.getImages() != null) {
            List<PropertyResponse.ImageResponse> imageResponses = property.getImages().stream().map(img -> {
                PropertyResponse.ImageResponse ir = new PropertyResponse.ImageResponse();
                ir.setId(img.getId());
                ir.setImageUrl(img.getImageUrl());
                ir.setIsThumbnail(img.getIsThumbnail());
                ir.setSortOrder(img.getSortOrder());
                return ir;
            }).collect(Collectors.toList());
            response.setImages(imageResponses);
        }
        return response;
    }
}
