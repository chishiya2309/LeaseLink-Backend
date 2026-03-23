package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.reponse;

import jakarta.persistence.*;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Role;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;

import java.time.OffsetDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

public class UserResponse {
    private UUID id;

    private String fullName;

    private String email;

    private String phone;

    private UserStatus status;

    private OffsetDateTime lastLoginAt;
}
