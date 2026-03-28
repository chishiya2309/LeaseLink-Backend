package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response;

import lombok.Getter;
import lombok.Setter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;

import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Setter
public class AdminUserResponse {
    private UUID id;
    private String fullName;
    private String email;
    private String phone;
    private UserStatus status;
    private String roleCode;
    private String roleName;
    private OffsetDateTime createdAt;
    private OffsetDateTime lastLoginAt;
    private String lockReason;
}
