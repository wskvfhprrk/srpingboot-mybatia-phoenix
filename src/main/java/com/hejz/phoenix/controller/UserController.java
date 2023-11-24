package com.hejz.phoenix.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.hejz.phoenix.dao.UserDao;
import com.hejz.phoenix.entity.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * @author 21061
 */
@RestController
@Slf4j
public class UserController {
    @Autowired
    private UserDao userDao;

    @GetMapping("page")
    public List<User> getPage() {
        PageHelper.startPage(1, 10);
        List<User> users = userDao.listAll();
        PageInfo<User> pageInfo = new PageInfo<>(users);
        log.info("getSize：{}条数据", pageInfo.getSize());
        log.info("getTotal：{}条数据", pageInfo.getTotal());
        return users;
    }

    @PostMapping("save")
    public User save(User user) {
        log.info("添加用户：{}", user);
        userDao.upsert(user);
        return user;
    }

    @DeleteMapping("delete")
    public void delete(Integer id) {
        log.info("删除用户，id={}", id);
        userDao.delete(id);
    }
}
