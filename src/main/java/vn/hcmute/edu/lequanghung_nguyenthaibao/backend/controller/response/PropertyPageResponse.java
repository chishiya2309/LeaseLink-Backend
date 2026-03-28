package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response;

import lombok.Getter;
import lombok.Setter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;

import java.util.List;

@Getter
@Setter
public class PropertyPageResponse extends PageResponseAbstract {
    private List<PropertyResponse> properties;
}
