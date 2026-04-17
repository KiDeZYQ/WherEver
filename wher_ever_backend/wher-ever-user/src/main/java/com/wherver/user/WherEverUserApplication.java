package com.wherver.user;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@EnableDiscoveryClient
@MapperScan("com.wherver.user.mapper")
@SpringBootApplication
public class WherEverUserApplication {

    public static void main(String[] args) {
        SpringApplication.run(WherEverUserApplication.class, args);
    }
}
