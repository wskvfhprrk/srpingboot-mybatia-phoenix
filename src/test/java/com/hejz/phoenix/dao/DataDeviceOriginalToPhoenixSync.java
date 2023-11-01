package com.hejz.phoenix.dao;

import org.apache.phoenix.jdbc.PhoenixDriver;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DataDeviceOriginalToPhoenixSync {
    public static void main(String[] args) throws SQLException {
        LocalDateTime begin = LocalDateTime.now();
        // MySQL连接详情
        String mysqlUrl = "jdbc:mysql://172.30.14.26:3306/cloud@air";
        String mysqlUser = "bcpark@test";
        String mysqlPassword = "jgjIWEiurhkEREOjtwrh24g";

        // Phoenix连接详情
        String phoenixJdbcUrl = "jdbc:phoenix:hd37,hd38,hd39:2181";
        Connection phoenixConnection = DriverManager.getConnection(phoenixJdbcUrl);
        PreparedStatement upsertStmt = null;
        try {
            upsertStmt = phoenixConnection.prepareStatement("UPSERT INTO \"air\".\"data_device_original\" VALUES (?, ?, ?, ?)");

            for (int i = 0; i <= 200; i++) {
                String sql = "SELECT * FROM data_device_original LIMIT 1000 OFFSET " + i * 1000;
                List<Map<String, Object>> mysqlDataList = fetchMySQLData(mysqlUrl, mysqlUser, mysqlPassword, sql);
                System.out.println("i=========" + i);
                if (mysqlDataList.size() == 0) {
                    break;
                }
                for (Map map : mysqlDataList) {
                    upsertStmt.setLong(1, (Long) map.get("id"));
                    upsertStmt.setString(2, String.valueOf(map.get("topic")));
                    Date create_time;

                    if (String.valueOf(map.get("create_time")).length() == 19) {
                        create_time = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(String.valueOf(map.get("create_time")));
                    } else {
                        create_time = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(map.get("create_time") + ":00");
                    }

                    upsertStmt.setDate(3, new java.sql.Date(create_time.getTime()));
                    upsertStmt.setString(4, map.get("content").toString());
                    upsertStmt.executeUpdate();
                }
                phoenixConnection.commit();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (upsertStmt != null) {
//                try {
//                    Thread.sleep(500000L);
//                } catch (InterruptedException e) {
//                    e.printStackTrace();
//                }
                upsertStmt.close();
            }
            phoenixConnection.close();
        }

        LocalDateTime end = LocalDateTime.now();
        Duration between = Duration.between(begin, end);
        System.out.println("====数据同步完毕用时间： " + between.getSeconds() + " 秒==");
    }

    public static List<Map<String, Object>> fetchMySQLData(String jdbcUrl, String user, String password, String sql) {
        List<Map<String, Object>> dataList = new ArrayList<>();

        try {
            // Manually load the MySQL driver class
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection connection = DriverManager.getConnection(jdbcUrl, user, password)) {
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    try (ResultSet resultSet = statement.executeQuery()) {
                        ResultSetMetaData metaData = resultSet.getMetaData();
                        int columnCount = metaData.getColumnCount();

                        while (resultSet.next()) {
                            Map<String, Object> row = new HashMap<>();
                            for (int i = 1; i <= columnCount; i++) {
                                String columnName = metaData.getColumnName(i);
                                Object value = resultSet.getObject(i);
                                row.put(columnName, value);
                            }
                            dataList.add(row);
                        }
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }

        return dataList;
    }

//    public static void main(String[] args) {
//        String mysqlJdbcUrl = "jdbc:mysql://mysql_host:3306/mysql_database";
//        String mysqlUser = "mysql_user";
//        String mysqlPassword = "mysql_password";
//
//        MySQLDataFetcher dataFetcher = new MySQLDataFetcher();
//        List<Map<String, Object>> mysqlDataList = dataFetcher.fetchMySQLData(mysqlJdbcUrl, mysqlUser, mysqlPassword);
//
//        // Now you have the MySQL data in the mysqlDataList as a list of maps
//        // You can proceed to insert it into Phoenix
//    }
}
