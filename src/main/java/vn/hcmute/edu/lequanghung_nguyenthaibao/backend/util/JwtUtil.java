package vn.hcmute.edu.lequanghung_nguyenthaibao.backend.util;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.User;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Role;
import vn.hcmute.edu.lequanghung_nguyenthaibao.backend.model.Permission;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import java.util.UUID;

@Component
public class JwtUtil {

    @Value("${vn.hcmute.edu.jwt.secret:MySecretKeyNeedsToBeVeryLongToSupportHS512AlgorithmForSecurityPurpose123456}")
    private String jwtSecret;

    @Value("${vn.hcmute.edu.jwt.expirationMs:3600000}") // 1 hour
    private int jwtExpirationMs;

    private SecretKey getSigningKey() {
        byte[] keyBytes = this.jwtSecret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String generateAccessToken(User user, Role selectedRole, UUID sessionId) {
        String rolesStr = user.getRoles().stream()
                .map(Role::getCode)
                .collect(Collectors.joining(","));

        String permissionsStr = selectedRole.getPermissions().stream()
                .map(Permission::getCode)
                .collect(Collectors.joining(","));

        return Jwts.builder()
                .subject(user.getEmail())
                .id(UUID.randomUUID().toString()) // Access Token JTI
                .claim("userId", user.getId().toString())
                .claim("sid", sessionId.toString()) // Session ID to link for logout
                .claim("roles", rolesStr)
                .claim("permissions", permissionsStr)
                .claim("status", user.getStatus().name())
                .issuedAt(new Date())
                .expiration(new Date((new Date()).getTime() + jwtExpirationMs))
                .signWith(getSigningKey())
                .compact();
    }

    public boolean validateToken(String authToken) {
        try {
            io.jsonwebtoken.Jwts.parser().setSigningKey(getSigningKey()).build().parseClaimsJws(authToken);
            return true;
        } catch (Exception e) {
            System.err.println("❌ LỖI GIẢI MÃ JWT: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public io.jsonwebtoken.Claims getClaimsFromToken(String token) {
        return io.jsonwebtoken.Jwts.parser().setSigningKey(getSigningKey()).build().parseClaimsJws(token).getBody();
    }
}
