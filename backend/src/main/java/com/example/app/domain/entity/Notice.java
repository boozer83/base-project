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
public class Notice {
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
