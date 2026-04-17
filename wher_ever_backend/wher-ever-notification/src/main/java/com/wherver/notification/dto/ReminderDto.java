package com.wherver.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReminderDto {
    private Long id;
    private Long userId;
    private String title;
    private String content;
    private String locationName;
    private Double latitude;
    private Double longitude;
    private Integer fenceRadius;
    private Integer triggerType;
    private Integer status;
    private Integer repeatType;
}
