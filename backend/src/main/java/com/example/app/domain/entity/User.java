package com.example.app.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private Long id;
    private String googleId;
    private String email;
    private String name;
    private String picture;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
