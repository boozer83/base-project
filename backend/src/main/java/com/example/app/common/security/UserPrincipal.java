package com.example.app.common.security;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public class UserPrincipal {
    private final Long id;
    private final String email;
    private final String role;
}
