package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Setter
@Getter
public class AiSearchCriteria {
    private String roomType;
    private String area;
    private Short bedrooms;
    private Boolean allowPets;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private String keywordQuery;
    private Boolean isRealEstateQuery;
}
