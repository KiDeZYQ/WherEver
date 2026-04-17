package com.wherver.location;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@EnableDiscoveryClient
@MapperScan("com.wherver.location.mapper")
@SpringBootApplication
public class WherEverLocationApplication {

    public static void main(String[] args) {
        SpringApplication.run(WherEverLocationApplication.class, args);
    }
}
