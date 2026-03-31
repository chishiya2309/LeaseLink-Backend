package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NonNull;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.AiSearchCriteria;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.AiNLPService;

import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class GeminiNLPAiProvider implements AiNLPService {

    private static final String DEFAULT_GEMINI_API_BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models";
    private static final String DEFAULT_GEMINI_MODEL = "gemini-2.5-flash";

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    @Value("${gemini.api.base-url:" + DEFAULT_GEMINI_API_BASE_URL + "}")
    private String geminiApiBaseUrl;

    @Value("${gemini.api.model:" + DEFAULT_GEMINI_MODEL + "}")
    private String geminiModel;

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public GeminiNLPAiProvider() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public AiSearchCriteria extractSearchCriteria(String prompt) {
        String fullPrompt = getFullPrompt(prompt);

        try {
            Map<String, Object> requestBody = Map.of(
                    "contents", List.of(
                            Map.of("parts", List.of(
                                    Map.of("text", fullPrompt)
                            ))
                    )
            );

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-goog-api-key", geminiApiKey);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            String url = String.format("%s/%s:generateContent", geminiApiBaseUrl, geminiModel);

            String rawResponse = restTemplate.postForObject(url, entity, String.class);
            if (rawResponse == null || rawResponse.isBlank()) {
                return new AiSearchCriteria();
            }

            JsonNode response = objectMapper.readTree(rawResponse);
            JsonNode responseTextNode = response.path("candidates")
                    .path(0)
                    .path("content")
                    .path("parts")
                    .path(0)
                    .path("text");

            if (!responseTextNode.isMissingNode() && !responseTextNode.isNull()) {
                String jsonStr = responseTextNode.asText()
                        .replace("```json", "")
                        .replace("```", "")
                        .trim();
                return objectMapper.readValue(jsonStr, AiSearchCriteria.class);
            }
        } catch (Exception e) {
            log.error("Error calling Gemini API: {}", e.getMessage(), e);
        }

        return new AiSearchCriteria();
    }

    private @NonNull String getFullPrompt(String prompt) {
        if (geminiApiKey == null || geminiApiKey.isEmpty()) {
            throw new RuntimeException("Gemini API key is missing. Ai Search is unavailable.");
        }

        String systemInstruction = """
                Bạn là công cụ trích xuất thông tin tìm hiểu và thuê bất động sản (phòng trọ, nhà ở, căn hộ) sang JSON.
                Không bao giờ trả lời bằng text thường, chỉ xuất ra một chuỗi JSON hợp lệ.
                
                LUẬT LỌC NGHIÊM NGẶT (RẤT QUAN TRỌNG):
                Bạn phải phân tích ý định của người dùng. Nếu nội dung KHÔNG liên quan đến tìm kiếm, thuê hoặc hỏi về bất động sản (ví dụ: lời chào "hello", hỏi đáp ngoài lề "bún bò ở đâu", tán gẫu, hỏi thời tiết...), bạn PHẢI trả về JSON với chính xác một trường:
                { "isRealEstateQuery": false }
                Tuyệt đối không cố gắng nội suy hay gán các từ khóa linh tinh vào biểu mẫu tìm kiếm!
                
                Trái lại, nếu nội dung ĐÚNG LÀ nhu cầu tìm kiếm bất động sản hợp lệ, hãy thiết lập:
                "isRealEstateQuery" (boolean, LUÔN LUÔN trả về true),
                Cùng với các trường sau (chỉ bao gồm các trường có thông tin trong câu, không có thì để null hoặc bỏ qua):
                "roomType" (String, vi du: "Nhà", "Chung cư", "Căn hộ"),
                "area" (String, tên quận/huyện, vi du: "Hải Châu", "Cẩm Lệ"),
                "bedrooms" (Số nguyên, ví dụ: 1, 2, ...),
                "allowPets" (boolean, true nếu cho nuôi thú cưng, null nếu không đề cập),
                "minPrice" (số nguyên),
                "maxPrice" (số nguyên, lưu ý 10 củ hoặc 10 triệu = 10.000.000 VNĐ),
                "keywordQuery" (String ngắn chứa các từ khóa mô tả nhu cầu còn lại để so khớp title/description, vi du: "full nội thất, có ban công, yên tĩnh gần Cầu Rồng").
                
                Lưu ý: Với keywordQuery, không lặp lại area, roomType, bedrooms, allowPets, minPrice hoặc maxPrice nếu đã tách thành trường riêng.
                """;

        return systemInstruction + "\n\nNgười dùng: " + prompt;
    }
}
