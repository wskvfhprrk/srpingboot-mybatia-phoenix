# idea添加phoenix数据库管理

### 1、解压phoenix驱动，最好要与安装的驱动保持一致，或者使用maven包中的client的jar依赖包
    我使用maven包中的client的jar依赖包,就不解压

### 2、【Database】中添加phoenix驱动
#### 1）添加数据链接

![添加数据链接1](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_2.png)

![添加数据链接2](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_3.png)

![添加数据链接2](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_4.png)

![添加数据链接2](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_5.png)

** 严格按照以上步骤执行，有可能测试连接不成功的。请多试几次！ **

#### 2）测试
```sql

drop TABLE "user";
CREATE TABLE "user"(
        "id" bigint NOT NULL PRIMARY KEY,
        "name" varchar ,
        "age" integer ,
        "sex" varchar ,
        "date" date
);

upsert into "user" values (1,'张三',18,'男','2023-08-12 00:00:00');
upsert into "user" values (2,'李四',18,'男','2023-05-12 00:00:00');

select * from "user";
```
打开控制台

![添加数据链接2](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_6.png)

输出日志和结果

![添加数据链接2](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_8.png)

![添加数据链接2](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_11.png)

在phoneix客户端下查看表

![添加数据链接2](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_10.png)

**注意事项**
* 表名和字段名区分大小写，如果不用双引号都为大写字母，如图：
  
  ![区分表名大小写](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img.png)
  
  ![区分表名大小写](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_12.png)
  
* phoenix没有`int`类型，应改为`integer`;
* upsert时values里面值使用单引号，否则会报错。
  
  ![upsert时values里面值使用单引号](https://github.com/wskvfhprrk/srpingboot-mybatia-phoenix/blob/main/picture/img_13.png)
