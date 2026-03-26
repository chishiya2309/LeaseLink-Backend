package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller.response;

import lombok.Getter;
import lombok.Setter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.AiSearchCriteria;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.response.PropertyResponse;
import java.util.List;

@Setter
@Getter
public class AiSearchResponse {
    private String replyMessage;
    private AiSearchCriteria extractedCriteria;
    private List<PropertyResponse> properties;

    public AiSearchResponse(String replyMessage, AiSearchCriteria extractedCriteria, List<PropertyResponse> properties) {
        this.replyMessage = replyMessage;
        this.extractedCriteria = extractedCriteria;
        this.properties = properties;
    }
}
