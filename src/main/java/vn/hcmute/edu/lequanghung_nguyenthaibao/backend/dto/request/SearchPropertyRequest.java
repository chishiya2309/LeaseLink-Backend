package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.request;

import lombok.Data;
import java.io.Serializable;

import java.math.BigDecimal;

/**
 * Tất cả các trường đều nullable — nếu null thì bỏ qua điều kiện đó.
 */
@Data
public class SearchPropertyRequest implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long areaId;
    private Long roomTypeId;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private Short bedrooms;
    private boolean allowPets;
}
