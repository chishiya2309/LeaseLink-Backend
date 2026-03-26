package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository;

import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.AiSearchCriteria;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Property;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.PropertyStatus;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

public class PropertySpecification {
    public static Specification<Property> buildBasicAndAiSpecification(AiSearchCriteria criteria) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            predicates.add(cb.equal(root.get("status"), PropertyStatus.APPROVED));

            if (criteria == null) {
                return cb.and(predicates.toArray(new Predicate[0]));
            }

            if (criteria.getRoomType() != null && !criteria.getRoomType().isEmpty()) {
                Expression<String> roomTypeName = normalizedFieldExpression(cb, root.get("roomType").get("name"));
                predicates.add(buildFlexibleLikePredicate(cb, roomTypeName, criteria.getRoomType()));
            }

            if (criteria.getArea() != null && !criteria.getArea().isEmpty()) {
                Expression<String> areaName = normalizedFieldExpression(cb, root.get("area").get("name"));
                predicates.add(buildFlexibleLikePredicate(cb, areaName, criteria.getArea()));
            }

            if (criteria.getBedrooms() != null) {
                predicates.add(cb.equal(root.get("bedrooms"), criteria.getBedrooms()));
            }

            if (criteria.getAllowPets() != null) {
                predicates.add(cb.equal(root.get("allowPets"), criteria.getAllowPets()));
            }

            if (criteria.getMinPrice() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("monthlyPrice"), criteria.getMinPrice()));
            }

            if (criteria.getMaxPrice() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("monthlyPrice"), criteria.getMaxPrice()));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    private static Expression<String> normalizedFieldExpression(jakarta.persistence.criteria.CriteriaBuilder cb, Expression<String> field) {
        Expression<String> lowered = cb.lower(field);
        Expression<String> withSpaces = cb.function("replace", String.class, lowered, cb.literal("_"), cb.literal(" "));
        return cb.function("replace", String.class, withSpaces, cb.literal("-"), cb.literal(" "));
    }

    private static Predicate buildFlexibleLikePredicate(jakarta.persistence.criteria.CriteriaBuilder cb, Expression<String> field, String rawValue) {
        List<Predicate> variants = normalizedVariants(rawValue).stream()
                .map(value -> cb.like(field, "%" + value + "%"))
                .toList();

        return cb.or(variants.toArray(new Predicate[0]));
    }

    private static Set<String> normalizedVariants(String value) {
        Set<String> variants = new LinkedHashSet<>();
        String original = value.trim().toLowerCase(Locale.ROOT);
        if (!original.isEmpty()) {
            variants.add(compactSpaces(original));
        }

        String ascii = Normalizer.normalize(original, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd')
                .replace('Đ', 'd');

        ascii = compactSpaces(ascii);
        if (!ascii.isEmpty()) {
            variants.add(ascii);
        }

        return variants;
    }

    private static String compactSpaces(String value) {
        return value.replace('_', ' ')
                .replace('-', ' ')
                .replaceAll("\\s+", " ")
                .trim();
    }
}
