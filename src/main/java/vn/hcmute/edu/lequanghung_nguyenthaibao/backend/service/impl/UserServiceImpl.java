package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.config.BrevoProperties;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.AdminCreateHostRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ForgotPasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ResetPasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserLoginRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.VerifyResetCodeRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.AdminUserResponse;
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
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.PropertyService;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.UserService;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.util.JwtUtil;

import java.security.SecureRandom;
import java.time.OffsetDateTime;
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
    private final PasswordResetTokenTxService passwordResetTokenTxService;
    private final EmailService emailService;
    private final BrevoProperties brevoProperties;
    private final PropertyService propertyService;

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
            throw new AccountLockedException("Tài khoản của bạn đã bị khóa, vui lòng liên hệ admin nếu có thắc mắc");
        }

        Role selectedRole;
        if (StringUtils.hasText(request.getRole())) {
            selectedRole = user.getRoles().stream()
                    .filter(r -> r.getCode().equalsIgnoreCase(request.getRole()))
                    .findFirst()
                    .orElseThrow(() -> new InvalidCredentialsException("Tài khoản không có quyền truy cập vai trò này."));
        } else {
            // Pick ADMIN first if available, otherwise just the first one
            selectedRole = user.getRoles().stream()
                    .filter(r -> r.getCode().equalsIgnoreCase("ADMIN"))
                    .findFirst()
                    .orElseGet(() -> user.getRoles().stream().findFirst()
                            .orElseThrow(() -> new InvalidCredentialsException("Tài khoản chưa được gán vai trò.")));
        }

        user.setLastLoginAt(OffsetDateTime.now());
        userRepository.save(user);

        AuthSession session = new AuthSession();
        session.setUser(user);
        session.setIsActive(true);
        session.setExpiresAt(OffsetDateTime.now().plusDays(7));

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
        refreshTokenEntity.setExpiresAt(OffsetDateTime.now().plusDays(7));
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
                .refreshToken(refreshTokenEntity.getJti() + "." + plainRefreshToken)
                .user(userDto)
                .build();
    }

    @Override
    @Transactional
    public LoginResponse refreshToken(String refreshToken) {
        String[] parts = refreshToken.split("\\.");
        if (parts.length != 2) {
            throw new InvalidCredentialsException("Refresh Token không hợp lệ");
        }

        UUID jti = UUID.fromString(parts[0]);
        String plainToken = parts[1];

        RefreshToken refreshTokenEntity = refreshTokenRepository.findByJti(jti)
                .orElseThrow(() -> new InvalidCredentialsException("Refresh Token không tồn tại hoặc đã bị vô hiệu hóa"));

        if (refreshTokenEntity.getRevokedAt() != null) {
            authSessionRepository.findById(refreshTokenEntity.getSession().getId()).ifPresent(s -> {
                s.setIsActive(false);
                authSessionRepository.save(s);
            });
            refreshTokenRepository.revokeBySessionId(
                    refreshTokenEntity.getSession().getId(),
                    "Refresh token reuse detected",
                    OffsetDateTime.now()
            );
            throw new InvalidCredentialsException("Refresh Token đã được sử dụng trước đó. Vui lòng đăng nhập lại.");
        }

        if (refreshTokenEntity.getExpiresAt().isBefore(OffsetDateTime.now())) {
            throw new InvalidCredentialsException("Refresh Token đã hết hạn. Vui lòng đăng nhập lại.");
        }

        if (!passwordEncoder.matches(plainToken, refreshTokenEntity.getTokenHash())) {
            throw new InvalidCredentialsException("Refresh Token không chính xác.");
        }

        User user = refreshTokenEntity.getUser();
        AuthSession session = refreshTokenEntity.getSession();
        Role selectedRole = user.getRoles().stream().findFirst().orElseThrow();

        String newAccessToken = jwtUtil.generateAccessToken(user, selectedRole, session.getId());

        String newPlainRefreshToken = generateRandomTokenString();
        RefreshToken newRefreshTokenEntity = new RefreshToken();
        newRefreshTokenEntity.setSession(session);
        newRefreshTokenEntity.setUser(user);
        newRefreshTokenEntity.setJti(UUID.randomUUID());
        newRefreshTokenEntity.setTokenHash(passwordEncoder.encode(newPlainRefreshToken));
        newRefreshTokenEntity.setExpiresAt(OffsetDateTime.now().plusDays(7));
        refreshTokenRepository.save(newRefreshTokenEntity);

        refreshTokenEntity.setRevokedAt(OffsetDateTime.now());
        refreshTokenEntity.setReplacedByToken(newRefreshTokenEntity);
        refreshTokenEntity.setRevokeReason("Rotated");
        refreshTokenRepository.save(refreshTokenEntity);

        UserResponse userDto = new UserResponse();
        userDto.setId(user.getId());
        userDto.setEmail(user.getEmail());
        userDto.setFullName(user.getFullName());
        userDto.setStatus(user.getStatus());
        userDto.setRole(selectedRole);

        return LoginResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshTokenEntity.getJti() + "." + newPlainRefreshToken)
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
        revokedJti.setExpiresAt(now.plusHours(1));
        revokedJtiRepository.save(revokedJti);

        authSessionRepository.findById(sessionId).ifPresent(session -> {
            session.setIsActive(false);
            authSessionRepository.save(session);
            refreshTokenRepository.revokeBySessionId(sessionId, "User logged out", now);
        });
    }

    @Override
    public void forgotPassword(ForgotPasswordRequest request) {
        log.info("Xử lý quên mật khẩu cho user: {}", request.getEmail());
        // 1. Generate OTP and save to DB in a short transaction
        User user = userRepository.findByEmail(request.getEmail()).orElse(null);
        if (user == null) return;


        String otpCode = generateOtpCode();
        int expiryMinutes = brevoProperties.getResetCodeExpiryMinutes();
        String fullName = user.getFullName();
        String email = user.getEmail();

        // Execute DB writes through a separate proxied bean so @Transactional is applied.
        passwordResetTokenTxService.createResetToken(user, otpCode, expiryMinutes);

        // 2. Send email OUTSIDE the transaction
        emailService.sendPasswordResetOtp(
                email,
                fullName,
                otpCode,
                expiryMinutes
        );

        log.info("Đã tạo và gửi password reset OTP cho email {}", email);
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

    @Override
    @Transactional
    public UUID adminCreateHost(AdminCreateHostRequest request) {
        log.info("[ADMIN] Tạo tài khoản Host mới cho email: {}", request.getEmail());

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ResourceAlreadyExistsException("Email này đã tồn tại trong hệ thống.");
        }
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new ResourceAlreadyExistsException("Số điện thoại này đã tồn tại trong hệ thống.");
        }

        String rawPassword = generateRandomPassword();

        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        user.setStatus(UserStatus.ACTIVE);

        Role hostRole = roleRepository.findByCode("HOST")
                .orElseThrow(() -> new RuntimeException("Lỗi hệ thống: Role HOST không tồn tại trong database"));
        user.getRoles().add(hostRole);
        userRepository.save(user);
        log.info("[ADMIN] Đã tạo Host ID: {}", user.getId());

        emailService.sendHostCredentialEmail(request.getEmail(), request.getFullName(), rawPassword);

        return user.getId();
    }

    @Override
    @Transactional
    public AdminUserResponse adminToggleUserStatus(UUID userId, UserStatus newStatus, String reason, UUID currentAdminId) {
        log.info("[ADMIN] Thay đổi trạng thái user {} -> {}, bởi admin {}", userId, newStatus, currentAdminId);

        if (userId.equals(currentAdminId)) {
            throw new IllegalArgumentException("Admin không thể tự khóa tài khoản của chính mình.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng với ID: " + userId));

        user.setStatus(newStatus);

        if (newStatus == UserStatus.LOCKED) {
            user.setLockReason(reason);
            // Revoke all sessions
            authSessionRepository.deactivateAllByUser(user);
            refreshTokenRepository.revokeAllByUser(user, "Admin locked account: " + reason, OffsetDateTime.now());
            log.info("[ADMIN] Đã thu hồi toàn bộ session của user {}", userId);
            // Hide all properties
            propertyService.hidePropertiesByOwner(userId);
        } else if (newStatus == UserStatus.ACTIVE) {
            user.setLockReason(null);
        }

        userRepository.save(user);
        return mapToAdminUserResponse(user);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AdminUserResponse> adminFindAllHosts(String query, UserStatus status, Pageable pageable) {
        return userRepository.findAllByRoleCode("HOST", query, status, pageable)
                .map(this::mapToAdminUserResponse);
    }

    private AdminUserResponse mapToAdminUserResponse(User user) {
        AdminUserResponse resp = new AdminUserResponse();
        resp.setId(user.getId());
        resp.setFullName(user.getFullName());
        resp.setEmail(user.getEmail());
        resp.setPhone(user.getPhone());
        resp.setStatus(user.getStatus());
        resp.setLockReason(user.getLockReason());
        resp.setLastLoginAt(user.getLastLoginAt());
        resp.setCreatedAt(user.getCreatedAt());
        user.getRoles().stream().findFirst().ifPresent(role -> {
            resp.setRoleCode(role.getCode());
            resp.setRoleName(role.getName());
        });
        return resp;
    }

    private String generateRandomPassword() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[6];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
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

