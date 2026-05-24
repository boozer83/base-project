package com.example.app.service;

import com.example.app.domain.dto.MenuDto;
import com.example.app.domain.entity.Menu;
import com.example.app.mapper.MenuMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MenuService {

    private final MenuMapper menuMapper;

    public List<MenuDto.Response> getMenus(String role) {
        List<Menu> menus = menuMapper.findByRoles(buildAllowedRoles(role));
        return buildTree(menus, null);
    }

    private List<String> buildAllowedRoles(String role) {
        List<String> roles = new ArrayList<>(List.of("ALL"));
        if (role != null) {
            roles.add("USER");
            if ("ADMIN".equals(role)) {
                roles.add("ADMIN");
            }
        }
        return roles;
    }

    private List<MenuDto.Response> buildTree(List<Menu> all, Long parentId) {
        return all.stream()
                .filter(m -> Objects.equals(m.getParentId(), parentId))
                .sorted(Comparator.comparingInt(Menu::getSortOrder))
                .map(m -> {
                    List<MenuDto.Response> children = buildTree(all, m.getId());
                    return MenuDto.Response.builder()
                            .id(m.getId())
                            .name(m.getName())
                            .path(m.getPath())
                            .parentId(m.getParentId())
                            .sortOrder(m.getSortOrder())
                            .children(children)
                            .build();
                })
                .filter(m -> m.getPath() != null || !m.getChildren().isEmpty())
                .collect(Collectors.toList());
    }
}
