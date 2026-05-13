package com.example.app.service;

import com.example.app.common.exception.BusinessException;
import com.example.app.common.exception.ErrorCode;
import com.example.app.common.security.JwtUtil;
import com.example.app.domain.entity.User;
import io.jsonwebtoken.Claims;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final JwtUtil jwtUtil;

    public TokenPair generateTokens(User user) {
        String accessToken = jwtUtil.generateToken(user.getId(), user.getEmail(), user.getRole());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId(), user.getEmail(), user.getRole());
        return new TokenPair(accessToken, refreshToken);
    }

    public TokenPair refresh(String refreshToken) {
        if (!jwtUtil.validateToken(refreshToken)) {
            throw new BusinessException(ErrorCode.INVALID_TOKEN);
        }
        Claims claims = jwtUtil.parseToken(refreshToken);
        if (!"REFRESH".equals(claims.get("type", String.class))) {
            throw new BusinessException(ErrorCode.INVALID_TOKEN);
        }
        Long userId = Long.parseLong(claims.getSubject());
        String email = claims.get("email", String.class);
        String role = claims.get("role", String.class);

        User user = User.builder().id(userId).email(email).role(role).build();
        return generateTokens(user);
    }

    @Getter
    @AllArgsConstructor
    public static class TokenPair {
        private final String accessToken;
        private final String refreshToken;
    }
}
