package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "brevo")
public class BrevoProperties {
    private String apiKey;
    private String baseUrl = "https://api.brevo.com";
    private String senderEmail;
    private String senderName = "LeaseLink";
    private boolean sandbox = false;
    private int resetCodeExpiryMinutes = 10;
    private int resetTokenExpiryMinutes = 15;
    private int maxVerifyAttempts = 5;

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public String getSenderEmail() {
        return senderEmail;
    }

    public void setSenderEmail(String senderEmail) {
        this.senderEmail = senderEmail;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public boolean isSandbox() {
        return sandbox;
    }

    public void setSandbox(boolean sandbox) {
        this.sandbox = sandbox;
    }

    public int getResetCodeExpiryMinutes() {
        return resetCodeExpiryMinutes;
    }

    public void setResetCodeExpiryMinutes(int resetCodeExpiryMinutes) {
        this.resetCodeExpiryMinutes = resetCodeExpiryMinutes;
    }

    public int getResetTokenExpiryMinutes() {
        return resetTokenExpiryMinutes;
    }

    public void setResetTokenExpiryMinutes(int resetTokenExpiryMinutes) {
        this.resetTokenExpiryMinutes = resetTokenExpiryMinutes;
    }

    public int getMaxVerifyAttempts() {
        return maxVerifyAttempts;
    }

    public void setMaxVerifyAttempts(int maxVerifyAttempts) {
        this.maxVerifyAttempts = maxVerifyAttempts;
    }
}
