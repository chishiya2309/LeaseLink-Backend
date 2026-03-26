package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response;

import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.PropertyStatus;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public class PropertyResponse {

    private UUID id;
    private UUID hostId;
    private String hostName;
    private Long areaId;
    private String areaName;
    private Long roomTypeId;
    private String roomTypeName;
    private String title;
    private String description;
    private String addressLine;
    private BigDecimal monthlyPrice;
    private BigDecimal areaM2;
    private Short bedrooms;
    private Boolean allowPets;
    private PropertyStatus status;
    private List<ImageResponse> images;
    private OffsetDateTime createdAt;
    private String rejectedReason;
    
    public static class ImageResponse {
        private UUID id;
        private String imageUrl;
        private Boolean isThumbnail;
        private Integer sortOrder;

        public UUID getId() { return id; }
        public void setId(UUID id) { this.id = id; }
        public String getImageUrl() { return imageUrl; }
        public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
        public Boolean getIsThumbnail() { return isThumbnail; }
        public void setIsThumbnail(Boolean isThumbnail) { this.isThumbnail = isThumbnail; }
        public Integer getSortOrder() { return sortOrder; }
        public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getHostId() { return hostId; }
    public void setHostId(UUID hostId) { this.hostId = hostId; }
    public String getHostName() { return hostName; }
    public void setHostName(String hostName) { this.hostName = hostName; }
    public Long getAreaId() { return areaId; }
    public void setAreaId(Long areaId) { this.areaId = areaId; }
    public String getAreaName() { return areaName; }
    public void setAreaName(String areaName) { this.areaName = areaName; }
    public Long getRoomTypeId() { return roomTypeId; }
    public void setRoomTypeId(Long roomTypeId) { this.roomTypeId = roomTypeId; }
    public String getRoomTypeName() { return roomTypeName; }
    public void setRoomTypeName(String roomTypeName) { this.roomTypeName = roomTypeName; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getAddressLine() { return addressLine; }
    public void setAddressLine(String addressLine) { this.addressLine = addressLine; }
    public BigDecimal getMonthlyPrice() { return monthlyPrice; }
    public void setMonthlyPrice(BigDecimal monthlyPrice) { this.monthlyPrice = monthlyPrice; }
    public BigDecimal getAreaM2() { return areaM2; }
    public void setAreaM2(BigDecimal areaM2) { this.areaM2 = areaM2; }
    public Short getBedrooms() { return bedrooms; }
    public void setBedrooms(Short bedrooms) { this.bedrooms = bedrooms; }
    public Boolean getAllowPets() { return allowPets; }
    public void setAllowPets(Boolean allowPets) { this.allowPets = allowPets; }
    public PropertyStatus getStatus() { return status; }
    public void setStatus(PropertyStatus status) { this.status = status; }
    public List<ImageResponse> getImages() { return images; }
    public void setImages(List<ImageResponse> images) { this.images = images; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public String getRejectedReason() { return rejectedReason; }
    public void setRejectedReason(String rejectedReason) { this.rejectedReason = rejectedReason; }
}
