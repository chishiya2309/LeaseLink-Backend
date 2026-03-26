package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.config.BrevoProperties;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ForgotPasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ResetPasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserLoginRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.VerifyResetCodeRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.LoginResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.ResetPasswordVerifyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.UserResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.exception.AccountLockedException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.exception.InvalidCredentialsException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.exception.ResourceAlreadyExistsException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.AuthSession;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.PasswordResetToken;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.RefreshToken;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.RevokedJti;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Role;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.AuthSessionRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.PasswordResetTokenRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RefreshTokenRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RevokedJtiRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RoleRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.UserRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.EmailService;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.UserService;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.util.JwtUtil;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

@Service
@Slf4j(topic = "USER-SERVICE")
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthSessionRepository authSessionRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final RevokedJtiRepository revokedJtiRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final EmailService emailService;
    private final BrevoProperties brevoProperties;

    @Override
    public List<UserResponse> findAll() {
        return List.of();
    }

    @Override
    public UserResponse findById(UUID id) {
        return null;
    }

    @Override
    public UserResponse findByEmail(String email) {
        return null;
    }

    @Override
    public UUID save(UserRegisterRequest request) {
        log.info("Xử lý đăng ký tài khoản cho Email: {}", request.getEmail());

        if (!request.getPassword().equals(request.getPasswordConfirm())) {
            throw new IllegalArgumentException("Xác nhận mật khẩu không khớp. Vui lòng nhập lại.");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ResourceAlreadyExistsException(
                    "Email này đã được đăng ký. Vui lòng sử dụng Email khác hoặc Đăng nhập.");
        }

        if (userRepository.existsByPhone(request.getPhone())) {
            throw new ResourceAlreadyExistsException("Số điện thoại này đã được đăng ký");
        }

        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setStatus(UserStatus.PENDING);

        Role hostRole = roleRepository.findByCode("HOST")
                .orElseThrow(() -> new RuntimeException("Lỗi hệ thống: Role HOST không tồn tại trong database"));
        user.getRoles().add(hostRole);
        userRepository.save(user);
        log.info("Đăng ký thành công User ID: {}", user.getId());

        return user.getId();
    }

    @Override
    @Transactional
    public LoginResponse login(UserLoginRequest request, HttpServletRequest httpRequest) {
        log.info("Xử lý đăng nhập cho user: {}", request.getEmail());
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new InvalidCredentialsException("Tài khoản hoặc mật khẩu không chính xác"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new InvalidCredentialsException("Tài khoản hoặc mật khẩu không chính xác");
        }

        if (user.getStatus() == UserStatus.LOCKED) {
            throw new AccountLockedException("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin để mở khóa.");
        }

        Role selectedRole = user.getRoles().stream()
                .filter(r -> r.getCode().equalsIgnoreCase(request.getRole()))
                .findFirst()
                .orElseThrow(() -> new InvalidCredentialsException("Tài khoản không có quyền truy cập vai trò này."));

        user.setLastLoginAt(OffsetDateTime.now());
        userRepository.save(user);

        AuthSession session = new AuthSession();
        session.setUser(user);
        session.setIsActive(true);
        session.setExpiresAt(OffsetDateTime.now().plus(7, ChronoUnit.DAYS));

        if (httpRequest != null) {
            session.setIp(httpRequest.getRemoteAddr());
            session.setUserAgent(httpRequest.getHeader("User-Agent"));
        }
        session = authSessionRepository.save(session);

        String plainRefreshToken = generateRandomTokenString();
        RefreshToken refreshTokenEntity = new RefreshToken();
        refreshTokenEntity.setSession(session);
        refreshTokenEntity.setUser(user);
        refreshTokenEntity.setJti(UUID.randomUUID());
        refreshTokenEntity.setTokenHash(passwordEncoder.encode(plainRefreshToken));
        refreshTokenEntity.setExpiresAt(OffsetDateTime.now().plus(7, ChronoUnit.DAYS));
        refreshTokenRepository.save(refreshTokenEntity);

        String accessToken = jwtUtil.generateAccessToken(user, selectedRole, session.getId());

        UserResponse userDto = new UserResponse();
        userDto.setId(user.getId());
        userDto.setEmail(user.getEmail());
        userDto.setFullName(user.getFullName());
        userDto.setStatus(user.getStatus());
        userDto.setRole(selectedRole);

        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(plainRefreshToken)
                .user(userDto)
                .build();
    }

    @Override
    @Transactional
    public void logout(String jti, UUID sessionId, UUID userId) {
        log.info("Xử lý đăng xuất user: {}", userId);
        OffsetDateTime now = OffsetDateTime.now();

        RevokedJti revokedJti = new RevokedJti();
        revokedJti.setJti(UUID.fromString(jti));
        revokedJti.setUser(userRepository.getReferenceById(userId));
        revokedJti.setTokenType("access");
        revokedJti.setExpiresAt(now.plus(1, ChronoUnit.HOURS));
        revokedJtiRepository.save(revokedJti);

        authSessionRepository.findById(sessionId).ifPresent(session -> {
            session.setIsActive(false);
            authSessionRepository.save(session);
            refreshTokenRepository.revokeBySessionId(sessionId, "User logged out", now);
        });
    }

    @Override
    @Transactional
    public void forgotPassword(ForgotPasswordRequest request) {
        log.info("Xử lý quên mật khẩu cho user: {}", request.getEmail());
        userRepository.findByEmail(request.getEmail()).ifPresent(user -> {
            OffsetDateTime now = OffsetDateTime.now();
            passwordResetTokenRepository.consumeAllActiveByUser(user, now);

            String otpCode = generateOtpCode();
            PasswordResetToken token = new PasswordResetToken();
            token.setUser(user);
            token.setEmailSnapshot(user.getEmail());
            token.setOtpHash(passwordEncoder.encode(otpCode));
            token.setExpiresAt(now.plusMinutes(brevoProperties.getResetCodeExpiryMinutes()));
            passwordResetTokenRepository.save(token);

            emailService.sendPasswordResetOtp(
                    user.getEmail(),
                    user.getFullName(),
                    otpCode,
                    brevoProperties.getResetCodeExpiryMinutes()
            );

            log.info("Đã tạo password reset OTP cho email {}", user.getEmail());
        });
    }

    @Override
    @Transactional
    public ResetPasswordVerifyResponse verifyResetCode(VerifyResetCodeRequest request) {
        log.info("Xử lý xác thực mã OTP đặt lại mật khẩu cho user: {}", request.getEmail());
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Mã xác thực không hợp lệ hoặc đã hết hạn."));

        PasswordResetToken token = passwordResetTokenRepository
                .findFirstByUserAndConsumedAtIsNullOrderByCreatedAtDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("Mã xác thực không hợp lệ hoặc đã hết hạn."));

        OffsetDateTime now = OffsetDateTime.now();
        if (token.getExpiresAt().isBefore(now)) {
            token.setConsumedAt(now);
            passwordResetTokenRepository.save(token);
            throw new IllegalArgumentException("Mã xác thực không hợp lệ hoặc đã hết hạn.");
        }

        if (!passwordEncoder.matches(request.getCode(), token.getOtpHash())) {
            int nextAttemptCount = token.getAttemptCount() + 1;
            token.setAttemptCount(nextAttemptCount);

            if (nextAttemptCount >= brevoProperties.getMaxVerifyAttempts()) {
                token.setConsumedAt(now);
            }

            passwordResetTokenRepository.save(token);
            throw new IllegalArgumentException("Mã xác thực không hợp lệ hoặc đã hết hạn.");
        }

        String plainResetToken = generateRandomTokenString();
        token.setVerifiedAt(now);
        token.setResetTokenHash(passwordEncoder.encode(plainResetToken));
        token.setExpiresAt(now.plusMinutes(brevoProperties.getResetTokenExpiryMinutes()));
        token.setAttemptCount(0);
        passwordResetTokenRepository.save(token);

        return ResetPasswordVerifyResponse.builder()
                .email(user.getEmail())
                .resetToken(plainResetToken)
                .build();
    }

    @Override
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        log.info("Xử lý reset mật khẩu cho user: {}", request.getEmail());
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new IllegalArgumentException("Xác nhận mật khẩu không khớp.");
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Phiên đặt lại mật khẩu không hợp lệ hoặc đã hết hạn."));

        PasswordResetToken token = passwordResetTokenRepository
                .findFirstByUserAndConsumedAtIsNullAndVerifiedAtIsNotNullOrderByVerifiedAtDesc(user)
                .orElseThrow(() -> new IllegalArgumentException("Phiên đặt lại mật khẩu không hợp lệ hoặc đã hết hạn."));

        OffsetDateTime now = OffsetDateTime.now();
        if (token.getExpiresAt().isBefore(now) || token.getResetTokenHash() == null ||
                !passwordEncoder.matches(request.getResetToken(), token.getResetTokenHash())) {
            throw new IllegalArgumentException("Phiên đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        userRepository.save(user);

        token.setConsumedAt(now);
        passwordResetTokenRepository.save(token);

        authSessionRepository.deactivateAllByUser(user);
        refreshTokenRepository.revokeAllByUser(user, "Password reset", now);
    }

    private String generateRandomTokenString() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String generateOtpCode() {
        SecureRandom random = new SecureRandom();
        return String.format("%06d", random.nextInt(1_000_000));
    }
}
