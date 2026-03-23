package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ResetPasswordVerifyResponse {
    private String email;
    private String resetToken;
}
