package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request.PropertyRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.*;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.PropertyStatus;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.AreaRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.PropertyRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RoomTypeRepository;

import java.io.IOException;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Service
@RequiredArgsConstructor
public class PropertyServiceImpl implements PropertyService {

    private final PropertyRepository propertyRepository;
    private final AreaRepository areaRepository;
    private final RoomTypeRepository roomTypeRepository;
    private final S3Service s3Service;

    @Override
    @Transactional
    public PropertyResponse createProperty(PropertyRequest request, List<MultipartFile> images, MultipartFile video, User host) {
        if (images != null && images.size() > 10) {
            throw new IllegalArgumentException("Maximum 10 images are allowed per property posting.");
        }
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
        property.setStatus(PropertyStatus.PENDING); // UC02 Requirement

        try {
            if (video != null && !video.isEmpty()) {
                PropertyImage videoImage = new PropertyImage();
                videoImage.setImageUrl(s3Service.uploadFile(video));
                videoImage.setSortOrder(999);
                videoImage.setIsThumbnail(false);
                property.addImage(videoImage);
            }
            if (images != null && !images.isEmpty()) {
                for (int i = 0; i < images.size(); i++) {
                    MultipartFile file = images.get(i);
                    if (!file.isEmpty()) {
                        PropertyImage propertyImage = new PropertyImage();
                        propertyImage.setImageUrl(s3Service.uploadFile(file));
                        propertyImage.setSortOrder(i);
                        propertyImage.setIsThumbnail(i == 0);
                        property.addImage(propertyImage);
                    }
                }
            }
        } catch (IOException e) {
            throw new RuntimeException("Media upload failed: " + e.getMessage(), e);
        }

        return mapToResponse(propertyRepository.save(property));
    }

    @Override
    @Transactional
    public PropertyResponse updateProperty(UUID id, PropertyRequest request, List<MultipartFile> images, MultipartFile video, User host) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));

        if (!property.getHost().getId().equals(host.getId())) {
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
        property.setStatus(PropertyStatus.PENDING); // Spec Exception A1

        try {
            if (video != null && !video.isEmpty()) {
                if (property.getImages() != null) {
                    property.getImages().removeIf(img -> {
                        String url = img.getImageUrl().toLowerCase();
                        if (url.endsWith(".mp4") || url.endsWith(".mov") || url.endsWith(".webm")) {
                            s3Service.deleteFile(img.getImageUrl());
                            return true;
                        }
                        return false;
                    });
                }
                PropertyImage videoImage = new PropertyImage();
                videoImage.setImageUrl(s3Service.uploadFile(video));
                videoImage.setSortOrder(999);
                videoImage.setIsThumbnail(false);
                property.addImage(videoImage);
            }

            if (images != null && !images.isEmpty()) {
                if (images.size() > 10) throw new IllegalArgumentException("Maximum 10 images restricted.");
                
                if (property.getImages() != null) {
                    for (PropertyImage img : property.getImages()) {
                        s3Service.deleteFile(img.getImageUrl());
                    }
                    property.getImages().clear();
                }

                for (int i = 0; i < images.size(); i++) {
                    MultipartFile file = images.get(i);
                    if (!file.isEmpty()) {
                        PropertyImage propertyImage = new PropertyImage();
                        propertyImage.setImageUrl(s3Service.uploadFile(file));
                        propertyImage.setSortOrder(i);
                        propertyImage.setIsThumbnail(i == 0);
                        property.addImage(propertyImage);
                    }
                }
            }
        } catch (IOException e) {
            throw new RuntimeException("Media update failed: " + e.getMessage(), e);
        }

        return mapToResponse(propertyRepository.save(property));
    }

    @Override
    @Transactional
    public void softDeleteProperty(UUID id, User host) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));

        if (!property.getHost().getId().equals(host.getId())) {
            throw new IllegalArgumentException("You are not authorized to delete this property.");
        }

        property.setStatus(PropertyStatus.DELETED);
        property.setDeletedAt(java.time.OffsetDateTime.now());
        propertyRepository.save(property);
    }

    @Override
    public Page<PropertyResponse> getHostProperties(User host, Pageable pageable) {
        return propertyRepository.findByHost(host, pageable).map(this::mapToResponse);
    }

    @Override
    public PropertyResponse getProperty(UUID id) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        return mapToResponse(property);
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
