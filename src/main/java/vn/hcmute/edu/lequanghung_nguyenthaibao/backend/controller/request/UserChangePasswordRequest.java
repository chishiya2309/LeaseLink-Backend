package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request;

import lombok.Getter;

@Getter
public class UserChangePasswordRequest {
    private String email;
    private String password;
    private String confirmPassword;
}
