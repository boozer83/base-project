package com.example.app.service;

import com.example.app.domain.dto.UserDto;
import com.example.app.domain.entity.User;
import com.example.app.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserMapper userMapper;

    @Transactional
    public User saveOrUpdateUser(String googleId, String email, String name, String picture) {
        User existing = userMapper.findByGoogleId(googleId);
        if (existing != null) {
            User updated = User.builder()
                    .id(existing.getId())
                    .googleId(googleId)
                    .email(email)
                    .name(name)
                    .picture(picture)
                    .role(existing.getRole())
                    .build();
            userMapper.update(updated);
            return updated;
        }
        User newUser = User.builder()
                .googleId(googleId)
                .email(email)
                .name(name)
                .picture(picture)
                .role("USER")
                .build();
        userMapper.insert(newUser);
        return newUser;
    }

    @Transactional(readOnly = true)
    public User findByEmail(String email) {
        return userMapper.findByEmail(email);
    }

    @Transactional(readOnly = true)
    public UserDto getMyInfo(Long userId) {
        User user = userMapper.findById(userId);
        return UserDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .picture(user.getPicture())
                .role(user.getRole())
                .build();
    }
}
