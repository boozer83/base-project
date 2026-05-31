package com.example.app.service;

import com.example.app.domain.dto.UserDto;
import com.example.app.domain.entity.User;
import com.example.app.mapper.PermissionMapper;
import com.example.app.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserMapper userMapper;
    private final PermissionMapper permissionMapper;

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
                    .build();
            userMapper.update(updated);
            userMapper.assignDefaultRole(existing.getId());
            return updated;
        }
        User newUser = User.builder()
                .googleId(googleId)
                .email(email)
                .name(name)
                .picture(picture)
                .build();
        userMapper.insert(newUser);
        userMapper.assignDefaultRole(newUser.getId());
        return newUser;
    }

    @Transactional(readOnly = true)
    public User findByEmail(String email) {
        return userMapper.findByEmail(email);
    }

    @Transactional(readOnly = true)
    public List<String> getPermissions(Long userId) {
        return permissionMapper.findNamesByUserId(userId);
    }

    @Transactional(readOnly = true)
    public UserDto getMyInfo(Long userId) {
        User user = userMapper.findById(userId);
        List<String> roles = userMapper.findRoleNamesByUserId(userId);
        List<String> permissions = permissionMapper.findNamesByUserId(userId);
        return UserDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .picture(user.getPicture())
                .roles(roles)
                .permissions(permissions)
                .build();
    }
}
