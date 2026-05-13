package com.example.app.service;

import com.example.app.common.exception.BusinessException;
import com.example.app.common.exception.ErrorCode;
import com.example.app.common.security.UserPrincipal;
import com.example.app.domain.dto.NoticeDto;
import com.example.app.domain.entity.Notice;
import com.example.app.domain.entity.User;
import com.example.app.mapper.NoticeMapper;
import com.example.app.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class NoticeService {

    private final NoticeMapper noticeMapper;
    private final UserMapper userMapper;

    @Transactional(readOnly = true)
    public Map<String, Object> getNoticeList(int page, int size) {
        int offset = (page - 1) * size;
        List<Notice> notices = noticeMapper.findAll(offset, size);
        long total = noticeMapper.count();

        List<NoticeDto.ListItem> list = notices.stream()
                .map(n -> NoticeDto.ListItem.builder()
                        .id(n.getId())
                        .title(n.getTitle())
                        .authorName(n.getAuthorName())
                        .isPinned(n.isPinned())
                        .viewCount(n.getViewCount())
                        .createdAt(n.getCreatedAt())
                        .build())
                .toList();

        return Map.of("list", list, "total", total, "page", page, "size", size);
    }

    @Transactional
    public NoticeDto.Response getNotice(Long id) {
        Notice notice = noticeMapper.findById(id);
        if (notice == null) throw new BusinessException(ErrorCode.NOTICE_NOT_FOUND);
        noticeMapper.incrementViewCount(id);
        return toResponse(notice);
    }

    @Transactional
    public NoticeDto.Response createNotice(NoticeDto.Request req, UserPrincipal principal) {
        User user = userMapper.findById(principal.getId());
        Notice notice = Notice.builder()
                .title(req.getTitle())
                .content(req.getContent())
                .authorId(principal.getId())
                .authorName(user.getName())
                .isPinned(req.isPinned())
                .build();
        noticeMapper.insert(notice);
        return toResponse(noticeMapper.findById(notice.getId()));
    }

    @Transactional
    public NoticeDto.Response updateNotice(Long id, NoticeDto.Request req, UserPrincipal principal) {
        Notice existing = noticeMapper.findById(id);
        if (existing == null) throw new BusinessException(ErrorCode.NOTICE_NOT_FOUND);
        Notice updated = Notice.builder()
                .id(id)
                .title(req.getTitle())
                .content(req.getContent())
                .authorId(existing.getAuthorId())
                .authorName(existing.getAuthorName())
                .isPinned(req.isPinned())
                .viewCount(existing.getViewCount())
                .build();
        noticeMapper.update(updated);
        return toResponse(noticeMapper.findById(id));
    }

    @Transactional
    public void deleteNotice(Long id) {
        if (noticeMapper.findById(id) == null) throw new BusinessException(ErrorCode.NOTICE_NOT_FOUND);
        noticeMapper.delete(id);
    }

    private NoticeDto.Response toResponse(Notice n) {
        return NoticeDto.Response.builder()
                .id(n.getId())
                .title(n.getTitle())
                .content(n.getContent())
                .authorId(n.getAuthorId())
                .authorName(n.getAuthorName())
                .isPinned(n.isPinned())
                .viewCount(n.getViewCount())
                .createdAt(n.getCreatedAt())
                .updatedAt(n.getUpdatedAt())
                .build();
    }
}
