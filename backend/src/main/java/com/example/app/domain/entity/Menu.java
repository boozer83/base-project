package com.example.app.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Menu {
    private Long id;
    private String name;
    private String path;
    private Long parentId;
    private int sortOrder;
    private String permission;
    private boolean isActive;
}
