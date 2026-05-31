package com.example.app.mapper;

import com.example.app.domain.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper {
    User findByGoogleId(@Param("googleId") String googleId);
    User findByEmail(@Param("email") String email);
    User findById(@Param("id") Long id);
    void insert(User user);
    void update(User user);
    void assignDefaultRole(@Param("userId") Long userId);
    List<String> findRoleNamesByUserId(@Param("userId") Long userId);
}
