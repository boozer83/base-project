package com.example.app.controller;

import com.example.app.common.ApiResponse;
import com.example.app.common.security.UserPrincipal;
import com.example.app.domain.dto.UserDto;
import com.example.app.service.AuthService;
import com.example.app.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;
    private final AuthService authService;

    @GetMapping("/me")
    public ApiResponse<UserDto> getMyInfo(@AuthenticationPrincipal UserPrincipal principal) {
        return ApiResponse.ok(userService.getMyInfo(principal.getId()));
    }

    @PostMapping("/refresh")
    public ApiResponse<Map<String, String>> refresh(@RequestBody Map<String, String> body) {
        AuthService.TokenPair tokens = authService.refresh(body.get("refreshToken"));
        return ApiResponse.ok(Map.of(
                "accessToken", tokens.getAccessToken(),
                "refreshToken", tokens.getRefreshToken()
        ));
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout() {
        return ApiResponse.ok(null);
    }
}
