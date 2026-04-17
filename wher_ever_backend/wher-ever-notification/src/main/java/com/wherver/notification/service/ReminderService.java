package com.wherver.notification.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wherver.common.entity.Reminder;
import com.wherver.notification.dto.ReminderDto;
import com.wherver.notification.mapper.ReminderMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReminderService extends ServiceImpl<ReminderMapper, Reminder> {

    public ReminderDto createReminder(ReminderDto dto) {
        Reminder reminder = toEntity(dto);
        save(reminder);
        return toDto(reminder);
    }

    public ReminderDto updateReminder(Long id, ReminderDto dto) {
        Reminder existing = getById(id);
        if (existing == null) {
            return null;
        }
        existing.setTitle(dto.getTitle());
        existing.setContent(dto.getContent());
        existing.setLocationName(dto.getLocationName());
        existing.setLatitude(dto.getLatitude());
        existing.setLongitude(dto.getLongitude());
        existing.setFenceRadius(dto.getFenceRadius());
        existing.setTriggerType(dto.getTriggerType());
        existing.setStatus(dto.getStatus());
        existing.setRepeatType(dto.getRepeatType());
        updateById(existing);
        return toDto(existing);
    }

    public boolean deleteReminder(Long id) {
        return removeById(id);
    }

    public ReminderDto getReminderById(Long id) {
        Reminder reminder = getById(id);
        return reminder != null ? toDto(reminder) : null;
    }

    public List<ReminderDto> getRemindersByUserId(Long userId) {
        LambdaQueryWrapper<Reminder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Reminder::getUserId, userId);
        List<Reminder> reminders = list(wrapper);
        return reminders.stream().map(this::toDto).collect(Collectors.toList());
    }

    public List<ReminderDto> getActiveRemindersByUserId(Long userId) {
        LambdaQueryWrapper<Reminder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Reminder::getUserId, userId)
               .eq(Reminder::getStatus, 1);
        List<Reminder> reminders = list(wrapper);
        return reminders.stream().map(this::toDto).collect(Collectors.toList());
    }

    private ReminderDto toDto(Reminder reminder) {
        return ReminderDto.builder()
                .id(reminder.getId())
                .userId(reminder.getUserId())
                .title(reminder.getTitle())
                .content(reminder.getContent())
                .locationName(reminder.getLocationName())
                .latitude(reminder.getLatitude())
                .longitude(reminder.getLongitude())
                .fenceRadius(reminder.getFenceRadius())
                .triggerType(reminder.getTriggerType())
                .status(reminder.getStatus())
                .repeatType(reminder.getRepeatType())
                .build();
    }

    private Reminder toEntity(ReminderDto dto) {
        Reminder reminder = new Reminder();
        reminder.setId(dto.getId());
        reminder.setUserId(dto.getUserId());
        reminder.setTitle(dto.getTitle());
        reminder.setContent(dto.getContent());
        reminder.setLocationName(dto.getLocationName());
        reminder.setLatitude(dto.getLatitude());
        reminder.setLongitude(dto.getLongitude());
        reminder.setFenceRadius(dto.getFenceRadius());
        reminder.setTriggerType(dto.getTriggerType());
        reminder.setStatus(dto.getStatus());
        reminder.setRepeatType(dto.getRepeatType());
        return reminder;
    }
}
