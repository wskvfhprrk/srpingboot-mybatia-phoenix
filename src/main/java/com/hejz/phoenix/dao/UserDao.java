package com.hejz.phoenix.dao;

import com.hejz.phoenix.entity.User;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 */
public interface UserDao {
    @Select("SELECT * FROM \"air\".\"user\"")
    List<User> listAll();

    @Insert("upsert into \"air\".\"user\" (id,name,age,sex,date) values(#{id},#{name},#{age},#{sex},#{date})")
    void upstert(User user);
}