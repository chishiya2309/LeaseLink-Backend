package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.filter.JwtAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, JwtAuthenticationFilter jwtAuthenticationFilter)
            throws Exception {
        http
                // 1. Nói với Spring Security: "Hãy sử dụng cấu hình CORS bên WebMvcConfigurer
                // nhé!"
                .cors(Customizer.withDefaults())

                // 2. Tắt CSRF (Cross-Site Request Forgery): Rất cần thiết khi làm API cho
                // React/Mobile,
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
                                "/webjars/**")
                        .permitAll()

                        // Mở các endpoint không cần đăng nhập
                        .requestMatchers(HttpMethod.POST, "/users/register").permitAll()
                        .requestMatchers(HttpMethod.POST, "/users/login").permitAll()
                        .requestMatchers(HttpMethod.POST, "/users/refresh-token").permitAll()
                        .requestMatchers(HttpMethod.POST, "/users/forgot-password").permitAll()
                        .requestMatchers(HttpMethod.POST, "/users/verify-reset-code").permitAll()
                        .requestMatchers(HttpMethod.POST, "/users/reset-password").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/ai/search").permitAll()

                        // Chi Admin mới có quyền duyệt tin
                        .requestMatchers("/api/v1/properties/pending/**").hasRole("ADMIN")
                        .requestMatchers("/api/v1/properties/*/approve").hasRole("ADMIN")
                        .requestMatchers("/api/v1/properties/*/reject").hasRole("ADMIN")

                        // Quản lý bất động sản (Dashboard) - Chỉ HOST và ADMIN
                        .requestMatchers(HttpMethod.POST, "/api/v1/properties").hasRole("HOST")
                        .requestMatchers(HttpMethod.PUT, "/api/v1/properties/**").hasAnyRole("HOST", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/properties/**").hasAnyRole("HOST", "ADMIN")
                        .requestMatchers("/api/v1/properties/me").hasAnyRole("HOST", "ADMIN")

                        // Tất cả các request khác đều phải đăng nhập
                        .anyRequest().authenticated())
                .sessionManagement(session -> session.sessionCreationPolicy(
                        org.springframework.security.config.http.SessionCreationPolicy.STATELESS))
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }
}
