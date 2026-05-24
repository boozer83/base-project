package com.example.app.mapper;

import com.example.app.domain.entity.Notice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NoticeMapper {
    List<Notice> findAll(@Param("offset") int offset, @Param("limit") int limit,
                         @Param("sortBy") String sortBy, @Param("sortOrder") String sortOrder);
    long count();
    Notice findById(@Param("id") Long id);
    void insert(Notice notice);
    void update(Notice notice);
    void delete(@Param("id") Long id);
    void incrementViewCount(@Param("id") Long id);
}
