package com.example.app.service;

import com.example.app.common.exception.BusinessException;
import com.example.app.common.exception.ErrorCode;
import com.example.app.common.security.JwtUtil;
import io.jsonwebtoken.Claims;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final JwtUtil jwtUtil;
    private final UserService userService;

    public TokenPair generateTokens(Long userId, String email, List<String> permissions) {
        String accessToken = jwtUtil.generateToken(userId, email, permissions);
        String refreshToken = jwtUtil.generateRefreshToken(userId, email);
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
        List<String> permissions = userService.getPermissions(userId);
        return generateTokens(userId, email, permissions);
    }

    @Getter
    @AllArgsConstructor
    public static class TokenPair {
        private final String accessToken;
        private final String refreshToken;
    }
}
