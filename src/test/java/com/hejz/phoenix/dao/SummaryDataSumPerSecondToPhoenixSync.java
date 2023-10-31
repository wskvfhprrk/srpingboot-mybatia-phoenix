package com.hejz.phoenix.dao;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.*;

public class SummaryDataSumPerSecondToPhoenixSync {
    public static void main(String[] args) throws SQLException {
        LocalDateTime begin = LocalDateTime.now();
        // MySQL配置
        String mysqlUrl = "jdbc:mysql://172.30.14.26:3306/cloud@air";
        String mysqlUser = "bcpark@test";
        String mysqlPassword = "jgjIWEiurhkEREOjtwrh24g";

        // Phoenix配置
        String phoenixJdbcUrl = "jdbc:phoenix:hd37,hd38,hd39:2181";
        Connection phoenixConnection = DriverManager.getConnection(phoenixJdbcUrl);
        PreparedStatement upsertStmt =null;
        try {
            for (int i = 0; i < 500000; i++) {
                //从mysql中查询出来数据
                String sql = "SELECT * FROM summary_data_sum_per_second LIMIT 10000 OFFSET " + i * 10000;
                List<Map<String, Object>> mysqlDataList = fetchMySQLData(mysqlUrl, mysqlUser, mysqlPassword, sql);
                if (mysqlDataList.size() == 0) {
                    System.out.println("i=========="+i);
                    break;
                }
                // 插入进Phoenix表
                String upsertStatement = "UPSERT INTO \"air\".\"summary_data_sum_per_second\" VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                upsertStmt = phoenixConnection.prepareStatement(upsertStatement);
                //遍历插入数据
                for (Map map : mysqlDataList) {
                    upsertStmt.setLong(1, Long.parseLong(String.valueOf(map.get("id"))));
                    Date create_time =null;
                    //表中解析时间有误
                    if (String.valueOf(map.get("create_time")).length() == 19) {
                        create_time = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(String.valueOf(map.get("create_time")));
                    }else {
                        create_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(String.valueOf(map.get("create_time")).substring(0,10)+" "+String.valueOf(map.get("create_time")).substring(11,16)+":00");
                    }
                    upsertStmt.setDate(2, new java.sql.Date(create_time.getTime()));
                    upsertStmt.setInt(3, Integer.parseInt(String.valueOf(map.get("park_id"))));
                    upsertStmt.setString(4, String.valueOf(map.get("energy_consumption")));
                    upsertStmt.setString(5, String.valueOf(map.get("cooling_capacity")));
                    upsertStmt.setString(6, String.valueOf(map.get("cooling_capacity_unit")));
                    upsertStmt.setString(7, String.valueOf(map.get("second_consumption")));
                    upsertStmt.setString(8, String.valueOf(map.get("second_cooling_capacity")));
                    upsertStmt.setString(9, String.valueOf(map.get("second_eer")));
                    upsertStmt.setString(10, String.valueOf(map.get("average_load_rate")));
                    upsertStmt.setString(11, String.valueOf(map.get("consumptions")));
                    upsertStmt.setString(12, String.valueOf(map.get("running_current_curve")));
                    upsertStmt.setString(13, String.valueOf(map.get("water_temperature_curve")));
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
