-- WherEver Database Initialization Script

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS wher_ever DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE wher_ever;

-- User table (placeholder for future user service)
CREATE TABLE IF NOT EXISTS `sys_user` (
    `id` bigint NOT NULL COMMENT 'Primary key',
    `username` varchar(64) NOT NULL COMMENT 'Username',
    `password` varchar(128) NOT NULL COMMENT 'Password (encrypted)',
    `nickname` varchar(64) DEFAULT NULL COMMENT 'Nickname',
    `email` varchar(128) DEFAULT NULL COMMENT 'Email',
    `phone` varchar(32) DEFAULT NULL COMMENT 'Phone number',
    `avatar` varchar(256) DEFAULT NULL COMMENT 'Avatar URL',
    `status` tinyint DEFAULT '1' COMMENT 'Status: 0=disabled, 1=normal',
    `subscription_level` tinyint DEFAULT '1' COMMENT 'Subscription level: 1=free, 2=premium',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Create time',
    `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
    `deleted` tinyint DEFAULT '0' COMMENT 'Soft delete: 0=not deleted, 1=deleted',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System user table';

-- Reminder table placeholder
CREATE TABLE IF NOT EXISTS `reminder` (
    `id` bigint NOT NULL COMMENT 'Primary key',
    `user_id` bigint NOT NULL COMMENT 'User ID',
    `title` varchar(128) NOT NULL COMMENT 'Reminder title',
    `content` text COMMENT 'Reminder content',
    `location_name` varchar(256) DEFAULT NULL COMMENT 'Location name',
    `latitude` double DEFAULT NULL COMMENT 'Latitude',
    `longitude` double DEFAULT NULL COMMENT 'Longitude',
    `fence_radius` int DEFAULT '100' COMMENT 'Fence radius in meters',
    `trigger_type` tinyint DEFAULT '1' COMMENT 'Trigger type: 1=arrive, 2=leave, 3=both',
    `status` tinyint DEFAULT '1' COMMENT 'Status: 0=disabled, 1=enabled',
    `repeat_rule` varchar(128) DEFAULT NULL COMMENT 'Repeat rule (JSON)',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Create time',
    `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update time',
    `deleted` tinyint DEFAULT '0' COMMENT 'Soft delete',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Reminder table';

-- Trigger log table
CREATE TABLE IF NOT EXISTS `trigger_log` (
    `id` bigint NOT NULL COMMENT 'Primary key',
    `reminder_id` bigint NOT NULL COMMENT 'Reminder ID',
    `user_id` bigint NOT NULL COMMENT 'User ID',
    `trigger_type` tinyint NOT NULL COMMENT 'Trigger type: 1=arrive, 2=leave',
    `latitude` double DEFAULT NULL COMMENT 'Trigger latitude',
    `longitude` double DEFAULT NULL COMMENT 'Trigger longitude',
    `trigger_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Trigger time',
    `notification_sent` tinyint DEFAULT '0' COMMENT 'Notification sent: 0=no, 1=yes',
    PRIMARY KEY (`id`),
    KEY `idx_reminder_id` (`reminder_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_trigger_time` (`trigger_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Trigger log table';
