package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response;

import lombok.Getter;
import lombok.Setter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Role;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;

import java.util.UUID;

@Setter
@Getter
public class UserResponse {
    private UUID id;

    private String fullName;

    private String email;

    private String phone;

    private UserStatus status;

    private Role role;
}
