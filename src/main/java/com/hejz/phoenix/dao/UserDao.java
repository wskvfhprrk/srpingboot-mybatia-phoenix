package com.hejz.phoenix.dao;

import com.hejz.phoenix.entity.User;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 */
public interface UserDao {

    @Select("""
            SELECT * FROM "user"
            """)
    List<User> listAll();

    @Insert("""
            upsert into "user" ("id","name","age","sex","date") values(#{id},#{name},#{age},#{sex},#{date})
            """)
    void upsert(User user);
    @Delete("""
            delete from "user" where "id"=#{id}
            """)
    void delete(Integer id);
}