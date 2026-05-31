package com.example.app.controller;

import com.example.app.common.ApiResponse;
import com.example.app.common.security.UserPrincipal;
import com.example.app.domain.dto.MenuDto;
import com.example.app.service.MenuService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/menus")
@RequiredArgsConstructor
public class MenuController {

    private final MenuService menuService;

    @GetMapping
    public ApiResponse<List<MenuDto.Response>> getMenus(@AuthenticationPrincipal UserPrincipal principal) {
        List<String> permissions = principal != null ? principal.getPermissions() : List.of();
        return ApiResponse.ok(menuService.getMenus(permissions));
    }
}
