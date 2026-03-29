package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

public interface EmailService {
    void sendPasswordResetOtp(String recipientEmail, String recipientName, String otpCode, int expiryMinutes);

    void sendHostCredentialEmail(String recipientEmail, String recipientName, String rawPassword);
}
