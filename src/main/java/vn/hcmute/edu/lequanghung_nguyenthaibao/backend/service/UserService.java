package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import jakarta.servlet.http.HttpServletRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.LoginResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.UserResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserLoginRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;

import java.util.List;
import java.util.UUID;

public interface UserService {
    List<UserResponse> findAll();

    UserResponse findById(UUID id);

    UserResponse findByEmail(String email);

    UUID save(UserRegisterRequest request);

    LoginResponse login(UserLoginRequest request, HttpServletRequest httpServletRequest);

    void logout(String jti, UUID sessionId, UUID userId);
}
