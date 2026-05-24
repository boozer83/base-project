package com.example.app.domain.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

public class MenuDto {

    @Getter
    @Builder
    public static class Response {
        private Long id;
        private String name;
        private String path;
        private Long parentId;
        private int sortOrder;
        private List<Response> children;
    }
}
