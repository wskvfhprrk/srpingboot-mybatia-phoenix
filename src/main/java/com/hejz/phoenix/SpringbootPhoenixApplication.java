package com.hejz.phoenix;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * @author 21061
 */
@SpringBootApplication
@MapperScan("com.hejz.phoenix.dao")
public class SpringbootPhoenixApplication {
    public static void main(String[] args) {
        SpringApplication.run(SpringbootPhoenixApplication.class, args);
    }
}
