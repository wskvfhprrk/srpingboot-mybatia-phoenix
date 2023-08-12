package com.hejz.phoenix.dao;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.hejz.phoenix.entity.User;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;


@SpringBootTest
@Slf4j
class UserDaoTest {

    @Autowired
    private UserDao userDao;

    @Test
    void listAll() {
        List<User> users = userDao.listAll();
        for (User user : users) {
            System.out.println(user);
        }
    }

    @Test
    void page(){
        PageHelper.startPage(1, 10);
        List<User> users = userDao.listAll();
        PageInfo<User> pageInfo=new PageInfo<>(users);
        log.info("getSize：{}条数据",pageInfo.getSize());
        log.info("getTotal：{}条数据",pageInfo.getTotal());
        for (User user : users) {
            System.out.println(user);
        }
    }

    @Test
    void upsert(){
        LocalDateTime begin=LocalDateTime.now();
        for (int i = 0; i < 100000; i++) {
            User user=new User(i,"张三"+i,i,"男", new Date(System.currentTimeMillis()));
            userDao.upstert(user);
        }
        LocalDateTime end=LocalDateTime.now();
        Duration between = Duration.between(begin, end);
        System.out.println(between.getSeconds());
    }
}