package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.config.BrevoProperties;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.exception.ExternalServiceException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.EmailService;

import java.util.List;
import java.util.Map;

@Service
@Slf4j(topic = "BREVO-EMAIL")
@RequiredArgsConstructor
public class BrevoEmailService implements EmailService {

    private final BrevoProperties brevoProperties;
    private final RestClient.Builder restClientBuilder;

    @Override
    public void sendPasswordResetOtp(String recipientEmail, String recipientName, String otpCode, int expiryMinutes) {
        validateConfiguration();

        RestClient.RequestBodySpec request = restClientBuilder
                .baseUrl(normalizeBaseUrl(brevoProperties.getBaseUrl()))
                .build()
                .post()
                .uri("/v3/smtp/email")
                .header("accept", "application/json")
                .header("content-type", "application/json")
                .header("api-key", brevoProperties.getApiKey());

        if (brevoProperties.isSandbox()) {
            request = request.header("X-Sib-Sandbox", "drop");
        }

        Map<String, Object> payload = Map.of(
                "sender", Map.of(
                        "name", brevoProperties.getSenderName(),
                        "email", brevoProperties.getSenderEmail()
                ),
                "to", List.of(Map.of(
                        "email", recipientEmail,
                        "name", recipientName == null || recipientName.isBlank() ? recipientEmail : recipientName
                )),
                "subject", "LeaseLink - Password reset verification code",
                "htmlContent", buildHtmlContent(recipientName, otpCode, expiryMinutes),
                "textContent", buildTextContent(recipientName, otpCode, expiryMinutes)
        );

        try {
            request
                    .body(payload)
                    .retrieve()
                    .toBodilessEntity();
        } catch (RestClientResponseException ex) {
            log.error("Brevo error: status={}, body={}", ex.getStatusCode(), ex.getResponseBodyAsString(), ex);
            String responseBody = ex.getResponseBodyAsString();
            String details = responseBody.isBlank() ? ex.getStatusText() : responseBody;
            throw new ExternalServiceException("Brevo từ chối gửi email reset mật khẩu: " + details);
        } catch (ExternalServiceException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Unexpected Brevo email error", ex);
            throw new ExternalServiceException("Không thể gửi email reset mật khẩu qua Brevo.");
        }
    }

    private void validateConfiguration() {
        if (isBlank(brevoProperties.getApiKey()) || isBlank(brevoProperties.getSenderEmail())) {
            throw new ExternalServiceException("Thiếu cấu hình Brevo. Hãy thiết lập BREVO_API_KEY và BREVO_SENDER_EMAIL.");
        }
    }

    private String buildHtmlContent(String recipientName, String otpCode, int expiryMinutes) {
        String safeName = recipientName == null || recipientName.isBlank() ? "bạn" : recipientName;
        return """
                <!DOCTYPE html>
                <html lang="vi">
                  <body style="margin:0;padding:24px;background:#f8fafc;font-family:Arial,sans-serif;color:#0f172a;">
                    <div style="max-width:520px;margin:0 auto;background:#ffffff;border:1px solid #e2e8f0;border-radius:24px;padding:32px;">
                      <p style="margin:0 0 12px;font-size:14px;color:#64748b;">LeaseLink</p>
                      <h1 style="margin:0 0 16px;font-size:24px;line-height:1.3;">Xác thực đặt lại mật khẩu</h1>
                      <p style="margin:0 0 16px;font-size:15px;line-height:1.7;">Xin chào %s, chúng tôi đã nhận được yêu cầu đặt lại mật khẩu cho tài khoản LeaseLink của bạn.</p>
                      <p style="margin:0 0 10px;font-size:15px;line-height:1.7;">Mã xác thực của bạn là:</p>
                      <div style="margin:0 0 18px;padding:16px;border-radius:18px;background:#eef2ff;text-align:center;font-size:32px;font-weight:700;letter-spacing:12px;color:#4f46e5;">%s</div>
                      <p style="margin:0 0 12px;font-size:14px;line-height:1.7;color:#475569;">Mã có hiệu lực trong %d phút. Nếu bạn không yêu cầu thao tác này, vui lòng bỏ qua email.</p>
                    </div>
                  </body>
                </html>
                """.formatted(safeName, otpCode, expiryMinutes);
    }

    private String buildTextContent(String recipientName, String otpCode, int expiryMinutes) {
        String safeName = recipientName == null || recipientName.isBlank() ? "bạn" : recipientName;
        return "Xin chào %s,%n%nMã xác thực đặt lại mật khẩu LeaseLink của bạn là: %s%nMã có hiệu lực trong %d phút.%n".formatted(
                safeName,
                otpCode,
                expiryMinutes
        );
    }

    private String normalizeBaseUrl(String baseUrl) {
        return baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
