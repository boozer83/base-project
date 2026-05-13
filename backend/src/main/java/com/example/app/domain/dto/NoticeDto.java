package com.example.app.domain.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

public class NoticeDto {

    @Getter
    @Builder
    public static class Request {
        @NotBlank(message = "제목을 입력해주세요.")
        private String title;

        @NotBlank(message = "내용을 입력해주세요.")
        private String content;

        private boolean isPinned;
    }

    @Getter
    @Builder
    public static class Response {
        private Long id;
        private String title;
        private String content;
        private Long authorId;
        private String authorName;
        private boolean isPinned;
        private int viewCount;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
    }

    @Getter
    @Builder
    public static class ListItem {
        private Long id;
        private String title;
        private String authorName;
        private boolean isPinned;
        private int viewCount;
        private LocalDateTime createdAt;
    }
}
