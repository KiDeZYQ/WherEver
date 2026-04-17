package com.wherver.user.controller;

import com.wherver.common.dto.ApiResponse;
import com.wherver.user.dto.*;
import com.wherver.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/register")
    public ApiResponse<LoginResponse> register(@RequestBody RegisterRequest request) {
        LoginResponse response = userService.register(request);
        if (response == null) {
            return ApiResponse.error("Username or email already exists");
        }
        return ApiResponse.success(response);
    }

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@RequestBody LoginRequest request) {
        LoginResponse response = userService.login(request);
        if (response == null) {
            return ApiResponse.error("Invalid username or password");
        }
        return ApiResponse.success(response);
    }

    @GetMapping("/{id}")
    public ApiResponse<UserDto> getUserById(@PathVariable Long id) {
        UserDto user = userService.getUserById(id);
        if (user == null) {
            return ApiResponse.error("User not found");
        }
        return ApiResponse.success(user);
    }

    @GetMapping("/username/{username}")
    public ApiResponse<UserDto> getUserByUsername(@PathVariable String username) {
        UserDto user = userService.getUserByUsername(username);
        if (user == null) {
            return ApiResponse.error("User not found");
        }
        return ApiResponse.success(user);
    }

    @PutMapping("/{id}/subscription")
    public ApiResponse<Boolean> updateSubscription(
            @PathVariable Long id,
            @RequestParam Integer level) {
        boolean success = userService.updateSubscriptionLevel(id, level);
        return ApiResponse.success(success);
    }
}
