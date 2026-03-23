package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) {
        http
                // 1. Nói với Spring Security: "Hãy sử dụng cấu hình CORS bên WebMvcConfigurer nhé!"
                .cors(Customizer.withDefaults())

                // 2. Tắt CSRF (Cross-Site Request Forgery): Rất cần thiết khi làm API cho React/Mobile,
                // vì sau này ta sẽ dùng Token (JWT) chứ không dùng Session Cookie mặc định.
                .csrf(AbstractHttpConfigurer::disable)

                // 3. Cấu hình phân quyền các đường dẫn (Endpoints)
                .authorizeHttpRequests(auth -> auth
                        // Mở cho Swagger/OpenAPI khi đang phát triển API
                        .requestMatchers(
                                "/swagger-ui.html",
                                "/swagger-ui/**",
                                "/v3/api-docs/**",
                                "/swagger-resources/**",
                                "/webjars/**"
                        ).permitAll()

                        // Mở endpoint đăng ký user, không cần đăng nhập
                        .requestMatchers(HttpMethod.POST, "/users/register").permitAll()

                        // Mở cửa tự do cho API test
                        .requestMatchers("/api/hello").permitAll()

                        // Tất cả các request khác đều phải đăng nhập
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}
