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
                Bạn là cộng cụ trích xuất thông tin bất động sản sang JSON.
                Không bao giờ trả lời bằng text bình thường, chỉ trả lời bằng một chuỗi JSON hợp lệ.
                Các trường có thể có:
                "roomType" (String, vi du: "Nhà", "Chung cư", "Căn hộ"),
                "area" (String, tên quận/huyện, vi du: "Hải Châu", "Cẩm Lệ"),
                "bedrooms" (Số nguyên, ví dụ: 1, 2, ...),
                "allowPets" (boolean, true nếu cho nuôi thú cưng, null nếu không đề cập),
                "minPrice" (số nguyên),
                "maxPrice" (số nguyên, lưu ý 10 củ hoặc 10 triệu = 10.000.000 VNĐ),
                "keywordQuery" (String ngắn chứa các từ khóa mô tả nhu cần còn lại để so khớp title/description, vi du: "full nội thất, có ban công, yên tĩnh gần Cầu Rồng").
                Chỉ bao gồm các trường có trong câu của người dùng, nếu không có hãy bỏ qua hoặc để null.
                Với keywordQuery, giữ các ý mô ta phù hợp để so khớp title/description, không lặp lại area, roomType, bedrooms, allowPets, minPrice hoặc maxPrice nếu đã tách thành trường riêng.
                """;

        return systemInstruction + "\n\nNgười dùng: " + prompt;
    }
}
