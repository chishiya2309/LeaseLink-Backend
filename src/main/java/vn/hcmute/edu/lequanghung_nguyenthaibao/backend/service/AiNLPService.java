package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.service;

import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.dto.AiSearchCriteria;

public interface AiNLPService {
    /**
     * Parses the user's natural language into structured search criteria.
     * @param prompt The natural language input from the user.
     * @return Extracted AiSearchCriteria object.
     */
    AiSearchCriteria extractSearchCriteria(String prompt);
}
