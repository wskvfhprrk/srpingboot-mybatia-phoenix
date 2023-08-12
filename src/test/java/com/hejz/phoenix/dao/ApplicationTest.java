package com.hejz.phoenix.dao;

import java.sql.*;

public class ApplicationTest {

    public static void main(String[] args) {
        Connection conn = null;
        try {

            Class.forName("org.apache.phoenix.jdbc.PhoenixDriver");
            conn = DriverManager.getConnection("jdbc:phoenix:hd37,hd38,hd39:2181");

            String sql = "SELECT * FROM user";
            PreparedStatement preparedStatement = conn.prepareStatement(sql);
            ResultSet rs = preparedStatement.executeQuery();

            System.out.println(sql);

            while (rs.next()) {
                System.out.println("name: " + rs.getString("name") + ", sex: " + rs.getString("sex"));
            }

            rs.close();
            conn.close();

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                }
            }
        }
    }
}
