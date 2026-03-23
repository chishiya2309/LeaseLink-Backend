package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.reponse.UserResponse;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserChangePasswordRequest;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request.UserRegisterRequest;

import java.util.List;
import java.util.UUID;

public interface UserService {
    List<UserResponse> findAll();

    UserResponse findById(UUID id);

    UserResponse findByEmail(String email);

    UUID save(UserRegisterRequest request);

    void changePassword(UserChangePasswordRequest request);

    void delete(UUID id);
}
