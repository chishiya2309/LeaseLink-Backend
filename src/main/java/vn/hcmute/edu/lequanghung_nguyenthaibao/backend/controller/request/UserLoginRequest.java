package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request;

import lombok.Getter;

@Getter
public class UserLoginRequest {
    private String email;
    private String password;
    private String role;
}
