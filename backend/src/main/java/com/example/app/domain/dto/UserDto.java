package com.example.app.domain.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class UserDto {
    private Long id;
    private String email;
    private String name;
    private String picture;
    private List<String> roles;
    private List<String> permissions;
}
