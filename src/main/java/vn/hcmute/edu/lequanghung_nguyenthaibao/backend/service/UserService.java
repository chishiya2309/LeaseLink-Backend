package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import jakarta.servlet.http.HttpServletRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.LoginResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.ResetPasswordVerifyResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response.UserResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ForgotPasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.ResetPasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserLoginRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.VerifyResetCodeRequest;

import java.util.List;
import java.util.UUID;

public interface UserService {
    List<UserResponse> findAll();

    UserResponse findById(UUID id);

    UserResponse findByEmail(String email);

    UUID save(UserRegisterRequest request);

    LoginResponse login(UserLoginRequest request, HttpServletRequest httpServletRequest);

    LoginResponse refreshToken(String refreshToken);

    void logout(String jti, UUID sessionId, UUID userId);

    void forgotPassword(ForgotPasswordRequest request);

    ResetPasswordVerifyResponse verifyResetCode(VerifyResetCodeRequest request);

    void resetPassword(ResetPasswordRequest request);
}
