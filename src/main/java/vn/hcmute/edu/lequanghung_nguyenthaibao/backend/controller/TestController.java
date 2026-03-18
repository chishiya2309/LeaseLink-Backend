package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class TestController {
    @GetMapping("/hello")
    public String sayHello() {
        return "Kết nối Spring Boot và React thành công!";
    }
}
