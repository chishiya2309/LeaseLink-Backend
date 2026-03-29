package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.enums.UserStatus;

@Getter
@Setter
public class ToggleUserStatusRequest {

    @NotNull(message = "Trạng thái không được để trống")
    private UserStatus status;

    private String reason;
}
