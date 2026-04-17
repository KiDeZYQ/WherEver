package com.wherver.notification.controller;

import com.wherver.common.dto.ApiResponse;
import com.wherver.notification.dto.ReminderDto;
import com.wherver.notification.service.ReminderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reminders")
@RequiredArgsConstructor
public class ReminderController {

    private final ReminderService reminderService;

    @PostMapping
    public ApiResponse<ReminderDto> createReminder(@RequestBody ReminderDto dto) {
        ReminderDto created = reminderService.createReminder(dto);
        return ApiResponse.success(created);
    }

    @PutMapping("/{id}")
    public ApiResponse<ReminderDto> updateReminder(
            @PathVariable Long id,
            @RequestBody ReminderDto dto) {
        ReminderDto updated = reminderService.updateReminder(id, dto);
        if (updated == null) {
            return ApiResponse.error("Reminder not found");
        }
        return ApiResponse.success(updated);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Boolean> deleteReminder(@PathVariable Long id) {
        boolean success = reminderService.deleteReminder(id);
        return ApiResponse.success(success);
    }

    @GetMapping("/{id}")
    public ApiResponse<ReminderDto> getReminderById(@PathVariable Long id) {
        ReminderDto reminder = reminderService.getReminderById(id);
        if (reminder == null) {
            return ApiResponse.error("Reminder not found");
        }
        return ApiResponse.success(reminder);
    }

    @GetMapping
    public ApiResponse<List<ReminderDto>> getRemindersByUserId(@RequestParam Long userId) {
        List<ReminderDto> reminders = reminderService.getRemindersByUserId(userId);
        return ApiResponse.success(reminders);
    }

    @GetMapping("/active")
    public ApiResponse<List<ReminderDto>> getActiveReminders(@RequestParam Long userId) {
        List<ReminderDto> reminders = reminderService.getActiveRemindersByUserId(userId);
        return ApiResponse.success(reminders);
    }
}
