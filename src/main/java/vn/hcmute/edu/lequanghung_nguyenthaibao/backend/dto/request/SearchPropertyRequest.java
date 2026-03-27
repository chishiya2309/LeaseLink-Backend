package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Tất cả các trường đều nullable — nếu null thì bỏ qua điều kiện đó.
 */
@Getter
@Setter
public class SearchPropertyRequest {
    private Long areaId;
    private Long roomTypeId;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private Short bedrooms;
    private boolean allowPets;
}
