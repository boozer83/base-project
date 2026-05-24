package com.example.app.mapper;

import com.example.app.domain.entity.Menu;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MenuMapper {
    List<Menu> findByRoles(@Param("roles") List<String> roles);
}
