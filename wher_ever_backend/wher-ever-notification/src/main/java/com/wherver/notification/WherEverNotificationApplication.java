package com.wherver.notification;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@EnableDiscoveryClient
@MapperScan("com.wherver.notification.mapper")
@SpringBootApplication
public class WherEverNotificationApplication {

    public static void main(String[] args) {
        SpringApplication.run(WherEverNotificationApplication.class, args);
    }
}
