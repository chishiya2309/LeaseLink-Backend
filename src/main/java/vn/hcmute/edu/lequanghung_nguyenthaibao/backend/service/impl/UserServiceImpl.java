package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.reponse.UserResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserChangePasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.exception.ResourceAlreadyExistsException;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Role;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.RoleRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.repository.UserRepository;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service.UserService;

import java.util.List;
import java.util.UUID;

@Service
@Slf4j(topic = "USER-SERVICE")
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

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

        if(!request.getPassword().equals(request.getPasswordConfirm())) {
            throw new IllegalArgumentException("Xác nhận mật khẩu không khớp. Vui lòng nhập lại.");
        }

        if(userRepository.existsByEmail(request.getEmail())) {
            throw new ResourceAlreadyExistsException("Email này đã được đăng ký. Vui lòng sử dụng Email khác hoặc Đăng nhập.");
        }

        if(userRepository.existsByPhone(request.getPhone())) {
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
    public void changePassword(UserChangePasswordRequest request) {

    }

    @Override
    public void delete(UUID id) {

    }
}
