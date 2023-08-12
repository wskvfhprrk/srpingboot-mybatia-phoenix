package com.hejz.phoenix.dao;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.*;

public class DataHistoricalToPhoenixSync {
    public static void main(String[] args) throws SQLException {
        LocalDateTime begin = LocalDateTime.now();
        // MySQL connection details
        String mysqlUrl = "jdbc:mysql://172.30.14.26:3306/cloud@air";
        String mysqlUser = "bcpark@test";
        String mysqlPassword = "jgjIWEiurhkEREOjtwrh24g";

        // Phoenix connection details
        String phoenixJdbcUrl = "jdbc:phoenix:hd37,hd38,hd39:2181";
        Connection phoenixConnection = DriverManager.getConnection(phoenixJdbcUrl);
        PreparedStatement upsertStmt =null;
        try {
            for (int i = 1400; i < 6210000; i++) {
                String sql = "SELECT * FROM data_historical LIMIT 10000 OFFSET " + i * 10000;
                List<Map<String, Object>> mysqlDataList = fetchMySQLData(mysqlUrl, mysqlUser, mysqlPassword, sql);
                //如果没有查询到数据就退出
                if (mysqlDataList.size() == 0) {
                    break;
                }
                // Insert data into Phoenix
                String upsertStatement = "UPSERT INTO \"air\".\"data_historical\" VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                 upsertStmt = phoenixConnection.prepareStatement(upsertStatement);

                for (Map map : mysqlDataList) {
                    upsertStmt.setLong(1, (Long) map.get("id"));
                    Date create_time =null;
                    //表中解析时间有误
                    if (String.valueOf(map.get("create_time")).length() == 19) {
                        create_time = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(String.valueOf(map.get("create_time")));
                    }else {
                        create_time = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(String.valueOf(map.get("create_time")+":00"));
                    }
                    upsertStmt.setDate(2, new java.sql.Date(create_time.getTime()));
                    upsertStmt.setInt(3, Integer.parseInt(String.valueOf(map.get("park_id"))));
                    upsertStmt.setString(4, String.valueOf(map.get("device_name")));
                    upsertStmt.setInt(5, Integer.parseInt(String.valueOf(map.get("type_id"))));
                    upsertStmt.setString(6, String.valueOf(map.get("type_name")));
                    upsertStmt.setInt(7, Integer.parseInt(String.valueOf(map.get("device_id"))));
                    upsertStmt.setString(8, String.valueOf(map.get("device_name")));
                    upsertStmt.setString(9, String.valueOf(map.get("parameter_name")));
                    upsertStmt.setInt(10, Integer.parseInt(String.valueOf(map.get("parameter_id"))));
                    upsertStmt.setDouble(11, Double.parseDouble(String.valueOf(map.get("data"))));
                    upsertStmt.setString(12, String.valueOf(map.get("unit")));
                    upsertStmt.executeUpdate();
                }
                phoenixConnection.commit();
            }
            upsertStmt.close();
            LocalDateTime end = LocalDateTime.now();
            Duration between = Duration.between(begin, end);
            System.out.println("====数据同步完毕用时间： " + between.getSeconds() + " 秒==");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            phoenixConnection.close();
        }
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
}
