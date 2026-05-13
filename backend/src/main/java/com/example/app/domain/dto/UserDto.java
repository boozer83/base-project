package com.example.app.domain.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class UserDto {
    private Long id;
    private String email;
    private String name;
    private String picture;
    private String role;
}
