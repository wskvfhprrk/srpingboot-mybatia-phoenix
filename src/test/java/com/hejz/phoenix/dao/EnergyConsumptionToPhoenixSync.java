package com.hejz.phoenix.dao;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.*;

public class EnergyConsumptionToPhoenixSync {
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
                String sql = "SELECT * FROM energy_consumption LIMIT 10000 OFFSET " + i * 10000;
                List<Map<String, Object>> mysqlDataList = fetchMySQLData(mysqlUrl, mysqlUser, mysqlPassword, sql);
                if (mysqlDataList.size() == 0) {
                    System.out.println("i====="+i);
                    break;
                }
                // 插入进Phoenix表
                String upsertStatement = "UPSERT INTO \"air\".\"energy_consumption\" VALUES (?, ?, ?, ?, ?, ?, ?)";
                upsertStmt = phoenixConnection.prepareStatement(upsertStatement);
                //遍历插入数据
                for (Map map : mysqlDataList) {
                    upsertStmt.setLong(1, (Long) map.get("id"));
                    Date create_time =null;
                    //表中解析时间有误
                    if (String.valueOf(map.get("created_at")).length() == 19) {
                        create_time = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(String.valueOf(map.get("created_at")));
                    }else {
                        create_time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(String.valueOf(map.get("created_at")).substring(0,10)+" "+String.valueOf(map.get("created_at")).substring(11,16)+":00");
                    }
                    upsertStmt.setDate(2, new java.sql.Date(create_time.getTime()));
                    upsertStmt.setInt(3, Integer.parseInt(String.valueOf(map.get("park_id"))));
                    if(map.get("unit_energy")==null||map.get("cooling_tower_energy")==null)continue;
                    upsertStmt.setDouble(4, Double.valueOf(String.valueOf(map.get("unit_energy"))));
                    upsertStmt.setDouble(5, Double.parseDouble(String.valueOf(map.get("cooling_pump_energy"))));
                    upsertStmt.setDouble(6, Double.parseDouble(String.valueOf(map.get("chilling_pump_energy"))));
                    upsertStmt.setDouble(7, Double.parseDouble(String.valueOf(map.get("cooling_tower_energy"))));
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
