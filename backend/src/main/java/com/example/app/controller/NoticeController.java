package com.example.app.controller;

import com.example.app.common.ApiResponse;
import com.example.app.common.security.UserPrincipal;
import com.example.app.domain.dto.NoticeDto;
import com.example.app.service.NoticeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/community/notices")
@RequiredArgsConstructor
public class NoticeController {

    private final NoticeService noticeService;

    @GetMapping
    public ApiResponse<Map<String, Object>> getList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.ok(noticeService.getNoticeList(page, size));
    }

    @GetMapping("/{id}")
    public ApiResponse<NoticeDto.Response> getOne(@PathVariable Long id) {
        return ApiResponse.ok(noticeService.getNotice(id));
    }

    @PostMapping
    public ApiResponse<NoticeDto.Response> create(
            @Valid @RequestBody NoticeDto.Request req,
            @AuthenticationPrincipal UserPrincipal principal) {
        return ApiResponse.ok(noticeService.createNotice(req, principal));
    }

    @PutMapping("/{id}")
    public ApiResponse<NoticeDto.Response> update(
            @PathVariable Long id,
            @Valid @RequestBody NoticeDto.Request req,
            @AuthenticationPrincipal UserPrincipal principal) {
        return ApiResponse.ok(noticeService.updateNotice(id, req, principal));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        noticeService.deleteNotice(id);
        return ApiResponse.ok(null);
    }
}
