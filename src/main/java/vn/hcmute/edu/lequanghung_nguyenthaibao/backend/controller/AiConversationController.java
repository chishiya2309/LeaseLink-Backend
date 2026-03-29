package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.AiSearchCriteria;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.AiSearchRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.AiSearchResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Property;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.PropertyRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.PropertySpecification;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.AiNLPService;

import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
@Slf4j
public class AiConversationController {

    private static final int MAX_RESULTS = 10;

    private final AiNLPService aiNLPService;
    private final PropertyRepository propertyRepository;

    @PostMapping("/search")
    public ResponseEntity<?> search(@RequestBody AiSearchRequest request, HttpServletRequest httpRequest) {
        String clientIp = httpRequest.getRemoteAddr();

        try {
            AiSearchCriteria criteria = aiNLPService.extractSearchCriteria(request.getMessage());

            if (criteria.getIsRealEstateQuery() != null && !criteria.getIsRealEstateQuery()) {
                return ResponseEntity.ok(new AiSearchResponse(
                        "Tin nhắn của bạn có vẻ không liên quan tới việc tìm kiếm hoặc thuê bất động sản. Mình là trợ lý LeaseLink, bạn hãy mô tả nhu cầu tìm thuê phòng hoặc căn hộ hợp lệ để mình hỗ trợ nhé!",
                        criteria, List.of()));
            }

            Specification<Property> spec = PropertySpecification.buildBasicAndAiSpecification(criteria);
            List<String> keywords = extractKeywords(criteria);

            List<PropertyResponse> responseList = propertyRepository.findAll(spec).stream()
                    .sorted(buildSearchRankingComparator(keywords))
                    .limit(MAX_RESULTS)
                    .map(this::mapToResponse)
                    .collect(Collectors.toList());

            String replyMessage = generateReplyMessage(criteria, responseList.size());
            return ResponseEntity.ok(new AiSearchResponse(replyMessage, criteria, responseList));
        } catch (Exception e) {
            log.error("AI Search failed for client IP {}: {}", clientIp, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(Map.of("message",
                            "Tính năng AI đang tạm gián đoạn. Bạn vui lòng thử lại sau hoặc chuyển sang bộ lọc tìm kiếm cơ bản."));
        }
    }

    private Comparator<Property> buildSearchRankingComparator(List<String> keywords) {
        return Comparator
                .comparingInt((Property property) -> countKeywordMatches(property, keywords))
                .reversed()
                .thenComparing(Property::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder()));
    }

    private List<String> extractKeywords(AiSearchCriteria criteria) {
        if (criteria == null || criteria.getKeywordQuery() == null || criteria.getKeywordQuery().isBlank()) {
            return List.of();
        }

        return Stream.of(criteria.getKeywordQuery().trim().toLowerCase(Locale.ROOT).split("\\s+"))
                .map(String::trim)
                .filter(token -> token.length() >= 2)
                .distinct()
                .collect(Collectors.toList());
    }

    private int countKeywordMatches(Property property, List<String> keywords) {
        if (keywords.isEmpty()) {
            return 0;
        }

        String title = safeLower(property.getTitle());
        String description = safeLower(property.getDescription());
        int score = 0;

        for (String keyword : keywords) {
            boolean inTitle = title.contains(keyword);
            boolean inDescription = description.contains(keyword);

            if (inTitle) {
                score += 2;
            }
            if (inDescription) {
                score += 1;
            }
        }

        return score;
    }

    private String safeLower(String value) {
        return value == null ? "" : value.toLowerCase(Locale.ROOT);
    }

    private String generateReplyMessage(AiSearchCriteria criteria, int matchCount) {
        if (matchCount == 0) {
            return "Mình chưa tìm thấy bất động sản thật sự phù hợp với mô tả của bạn. Bạn thử đổi một vài tiêu chí hoặc mô tả ngắn gọn hơn nhé.";
        }

        StringBuilder msg = new StringBuilder("Mình tìm được ").append(matchCount).append(" kết quả");
        if (criteria.getRoomType() != null) {
            msg.append(" dạng ").append(criteria.getRoomType());
        }
        if (criteria.getArea() != null) {
            msg.append(" ở ").append(criteria.getArea());
        }
        if (criteria.getBedrooms() != null) {
            msg.append(" với ").append(criteria.getBedrooms()).append(" phòng ngủ");
        }
        if (criteria.getKeywordQuery() != null && !criteria.getKeywordQuery().isBlank()) {
            msg.append(", đã ưu tiên theo mô tả \"").append(criteria.getKeywordQuery()).append("\"");
        }
        msg.append(". Bạn xem thử các lựa chọn bên dưới nhé.");
        return msg.toString();
    }

    private PropertyResponse mapToResponse(Property p) {
        PropertyResponse res = new PropertyResponse();
        res.setId(p.getId());
        if (p.getHost() != null) {
            res.setHostId(p.getHost().getId());
            res.setHostName(p.getHost().getFullName());
        }
        if (p.getArea() != null) {
            res.setAreaId(p.getArea().getId());
            res.setAreaName(p.getArea().getName());
        }
        if (p.getRoomType() != null) {
            res.setRoomTypeId(p.getRoomType().getId());
            res.setRoomTypeName(p.getRoomType().getName());
        }
        res.setTitle(p.getTitle());
        res.setDescription(p.getDescription());
        res.setAddressLine(p.getAddressLine());
        res.setMonthlyPrice(p.getMonthlyPrice());
        res.setAreaM2(p.getAreaM2());
        res.setBedrooms(p.getBedrooms());
        res.setAllowPets(p.getAllowPets());
        res.setStatus(p.getStatus());
        res.setCreatedAt(p.getCreatedAt());

        if (p.getImages() != null) {
            List<PropertyResponse.ImageResponse> imageResList = p.getImages().stream().map(img -> {
                PropertyResponse.ImageResponse imgRes = new PropertyResponse.ImageResponse();
                imgRes.setId(img.getId());
                imgRes.setImageUrl(img.getImageUrl());
                imgRes.setIsThumbnail(img.getIsThumbnail());
                imgRes.setSortOrder(img.getSortOrder());
                return imgRes;
            }).collect(Collectors.toList());
            res.setImages(imageResList);
        }
        return res;
    }
}
