package com.wherver.user.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wherver.user.dto.*;
import com.wherver.user.entity.User;
import com.wherver.user.mapper.UserMapper;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class UserService extends ServiceImpl<UserMapper, User> {

    public LoginResponse login(LoginRequest request) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, request.getUsername())
               .eq(User::getPassword, request.getPassword());
        User user = getOne(wrapper);

        if (user == null) {
            return null;
        }

        String token = generateToken(user);
        String refreshToken = generateRefreshToken(user);

        return LoginResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .user(toDto(user))
                .build();
    }

    public LoginResponse register(RegisterRequest request) {
        // Check if username exists
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, request.getUsername())
               .or()
               .eq(User::getEmail, request.getEmail());
        if (getOne(wrapper) != null) {
            return null; // User already exists
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword());
        user.setSubscriptionLevel(0); // Free tier
        user.setSessionId(UUID.randomUUID().toString());

        save(user);

        String token = generateToken(user);
        String refreshToken = generateRefreshToken(user);

        return LoginResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .user(toDto(user))
                .build();
    }

    public UserDto getUserById(Long id) {
        User user = getById(id);
        return user != null ? toDto(user) : null;
    }

    public UserDto getUserByUsername(String username) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username);
        User user = getOne(wrapper);
        return user != null ? toDto(user) : null;
    }

    public boolean updateSubscriptionLevel(Long userId, Integer level) {
        User user = getById(userId);
        if (user == null) {
            return false;
        }
        user.setSubscriptionLevel(level);
        return updateById(user);
    }

    private String generateToken(User user) {
        // In production, use JJWT library to generate real JWT token
        return "token_" + user.getId() + "_" + System.currentTimeMillis();
    }

    private String generateRefreshToken(User user) {
        return "refresh_" + user.getId() + "_" + UUID.randomUUID().toString();
    }

    private UserDto toDto(User user) {
        return UserDto.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .subscriptionLevel(user.getSubscriptionLevel())
                .build();
    }
}
