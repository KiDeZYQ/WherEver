package com.wherver.user.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.wherver.common.entity.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("users")
public class User extends BaseEntity {

    private String username;

    private String email;

    private String password;

    private Integer subscriptionLevel; // 0=free, 1=premium

    private String sessionId;
}
