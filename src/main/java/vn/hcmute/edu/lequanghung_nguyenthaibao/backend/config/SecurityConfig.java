package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. Nói với Spring Security: "Hãy sử dụng cấu hình CORS bên WebMvcConfigurer nhé!"
                .cors(Customizer.withDefaults())

                // 2. Tắt CSRF (Cross-Site Request Forgery): Rất cần thiết khi làm API cho React/Mobile,
                // vì sau này ta sẽ dùng Token (JWT) chứ không dùng Session Cookie mặc định.
                .csrf(AbstractHttpConfigurer::disable)

                // 3. Cấu hình phân quyền các đường dẫn (Endpoints)
                .authorizeHttpRequests(auth -> auth
                        // Mở cửa tự do cho API test
                        .requestMatchers("/api/hello").permitAll()

                        // Mở cửa cho các API không cần đăng nhập (ví dụ: xem danh sách sách, đăng nhập, đăng ký)
                        // .requestMatchers("/api/books/**", "/api/auth/**").permitAll()

                        // Tất cả các request khác (ví dụ: thêm/sửa/xóa sách, xem profile) ĐỀU PHẢI đăng nhập
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}
