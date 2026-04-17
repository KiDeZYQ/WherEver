package com.wherver.common.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("reminders")
public class Reminder extends BaseEntity {

    private Long userId;

    private String title;

    private String content;

    private String locationName;

    private Double latitude;

    private Double longitude;

    private Integer fenceRadius; // in meters

    private Integer triggerType; // 1=arrive, 2=leave, 3=both

    private Integer status; // 0=disabled, 1=enabled

    private Integer repeatType; // 0=none, 1=daily, 2=weekly, 3=monthly, 4=yearly
}
