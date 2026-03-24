package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

public class PropertyRequest {

    @NotNull(message = "Area ID is required")
    private Long areaId;

    @NotNull(message = "RoomType ID is required")
    private Long roomTypeId;

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    @NotBlank(message = "Address line is required")
    private String addressLine;

    @NotNull(message = "Monthly price is required")
    @Positive(message = "Price must be positive")
    private BigDecimal monthlyPrice;

    @NotNull(message = "Area (m2) is required")
    @Positive(message = "Area must be positive")
    private BigDecimal areaM2;

    private Short bedrooms;

    private Boolean allowPets = false;

    public Long getAreaId() {
        return areaId;
    }

    public void setAreaId(Long areaId) {
        this.areaId = areaId;
    }

    public Long getRoomTypeId() {
        return roomTypeId;
    }

    public void setRoomTypeId(Long roomTypeId) {
        this.roomTypeId = roomTypeId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getAddressLine() {
        return addressLine;
    }

    public void setAddressLine(String addressLine) {
        this.addressLine = addressLine;
    }

    public BigDecimal getMonthlyPrice() {
        return monthlyPrice;
    }

    public void setMonthlyPrice(BigDecimal monthlyPrice) {
        this.monthlyPrice = monthlyPrice;
    }

    public BigDecimal getAreaM2() {
        return areaM2;
    }

    public void setAreaM2(BigDecimal areaM2) {
        this.areaM2 = areaM2;
    }

    public Short getBedrooms() {
        return bedrooms;
    }

    public void setBedrooms(Short bedrooms) {
        this.bedrooms = bedrooms;
    }

    public Boolean getAllowPets() {
        return allowPets;
    }

    public void setAllowPets(Boolean allowPets) {
        this.allowPets = allowPets;
    }
}
