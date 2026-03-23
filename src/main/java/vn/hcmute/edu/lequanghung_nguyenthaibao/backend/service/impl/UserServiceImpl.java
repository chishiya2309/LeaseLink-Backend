package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.util.JwtUtil;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.LoginResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.UserResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserLoginRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.exception.AccountLockedException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.exception.InvalidCredentialsException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.exception.ResourceAlreadyExistsException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.*;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.AuthSessionRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RefreshTokenRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RoleRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.UserRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RevokedJtiRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.UserService;

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

        // 6. Tạo AuthSession (Ghi nhận lần đăng nhập thiết bị này)
        AuthSession session = new AuthSession();
        session.setUser(user);
        session.setIsActive(true);
        session.setExpiresAt(OffsetDateTime.now().plus(7, ChronoUnit.DAYS));

        if (httpRequest != null) {
            session.setIp(httpRequest.getRemoteAddr());
            session.setUserAgent(httpRequest.getHeader("User-Agent"));
        }
        session = authSessionRepository.save(session);

        // 7. Sinh Refresh Token dài hạn lưu Database
        String plainRefreshToken = generateRandomTokenString();
        RefreshToken refreshTokenEntity = new RefreshToken();
        refreshTokenEntity.setSession(session);
        refreshTokenEntity.setUser(user);
        refreshTokenEntity.setJti(UUID.randomUUID());
        // Mật khẩu có lưu dưới DB nhưng refresh token cần hash (bảo mật thêm 1 lớp)
        // tương tự password. Cách nhanh là dùng passwordEncoder
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

        // 10. Đóng gói kết quả gửi về Client
        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(plainRefreshToken) // Trả Plain cho Client cất.
                .user(userDto)
                .build();
    }

    private String generateRandomTokenString() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[32]; // 256 bits
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    @Transactional
    public void logout(String jti, UUID sessionId, UUID userId) {
        // 1. Lưu JTI vào danh sách đen (Blacklist) để Access Token không còn dùng được
        RevokedJti revokedJti = new RevokedJti();
        revokedJti.setJti(UUID.fromString(jti));
        revokedJti.setUser(userRepository.getReferenceById(userId));
        revokedJti.setTokenType("access");
        revokedJti.setExpiresAt(OffsetDateTime.now().plus(1, ChronoUnit.HOURS)); // Khớp với hạn của Access Token
        revokedJtiRepository.save(revokedJti);

        // 2. Thu hồi Refresh Token liên quan đến Session này
        authSessionRepository.findById(sessionId).ifPresent(session -> {
            session.setIsActive(false);
            authSessionRepository.save(session);
            refreshTokenRepository.revokeBySessionId(sessionId, "User logged out");
        });
    }
}
