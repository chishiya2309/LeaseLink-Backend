package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response;

import lombok.Getter;
import lombok.Setter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.PropertyStatus;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Setter
@Getter
public class PropertyResponse implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private UUID id;
    private UUID hostId;
    private String hostName;
    private String hostPhone;
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
    
    @Setter
    @Getter
    public static class ImageResponse implements Serializable {
        @Serial
        private static final long serialVersionUID = 1L;
        private UUID id;
        private String imageUrl;
        private Boolean isThumbnail;
        private Integer sortOrder;
    }

}
