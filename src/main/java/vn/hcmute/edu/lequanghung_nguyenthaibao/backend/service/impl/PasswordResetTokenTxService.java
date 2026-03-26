package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.PasswordResetToken;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.PasswordResetTokenRepository;

import java.time.OffsetDateTime;

@Service
@RequiredArgsConstructor
public class PasswordResetTokenTxService {

    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void createResetToken(User user, String otpCode, int expiryMinutes) {
        OffsetDateTime now = OffsetDateTime.now();
        passwordResetTokenRepository.consumeAllActiveByUser(user, now);

        PasswordResetToken token = new PasswordResetToken();
        token.setUser(user);
        token.setEmailSnapshot(user.getEmail());
        token.setOtpHash(passwordEncoder.encode(otpCode));
        token.setExpiresAt(now.plusMinutes(expiryMinutes));
        passwordResetTokenRepository.save(token);
    }
}

