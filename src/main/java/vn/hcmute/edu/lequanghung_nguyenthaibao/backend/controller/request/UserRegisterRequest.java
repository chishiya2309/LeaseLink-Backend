package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request;

import jakarta.persistence.*;
import lombok.Getter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;

import java.io.Serializable;
import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
public class UserRegisterRequest implements Serializable {
    private String fullName;

    private String email;

    private String phone;

    private String passwordPlaintext;

    private String passwordHash;
}
