package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request;

import lombok.Getter;

import java.io.Serializable;

@Getter
public class UserRegisterRequest implements Serializable {
    private String fullName;

    private String email;

    private String phone;

    private String password;

    private String passwordConfirm;
}
