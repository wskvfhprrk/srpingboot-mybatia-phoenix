-- user测试数据
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
-- pheneix创建表——与mysql字段对应
-- 同步原始数据表
drop TABLE "air"."data_power";
CREATE TABLE "air"."data_power" (
    "id" bigint NOT NULL PRIMARY KEY,
    "create_time" date,
    "park_id" bigint ,
    "type_id" bigint ,
    "device_id" bigint ,
    "device_name" varchar(255) ,
    "power" varchar(255)
);
select * from "air"."data_device_original";
select count(*) from "air"."data_device_original";

select * from "air"."data_power";
select count(*) from "air"."data_power";

drop TABLE "air"."data_historical";
CREATE TABLE "air"."data_historical" (
    "id" bigint NOT NULL PRIMARY KEY,
    "create_time" date ,
    "park_id" bigint ,
    "park_name" varchar(255) ,
    "device_id" bigint ,
    "device_name" varchar(255) ,
    "type_id" bigint ,
    "type_name" varchar(255),
    "parameter_name" varchar(255) ,
    "parameter_id" bigint ,
    "data" double ,
    "unit" varchar(255)
);

select * from "air"."data_historical";
select count(*) from "air"."data_historical";


drop TABLE "air"."device_status";
CREATE TABLE "air"."device_status" (
    "id" bigint NOT NULL PRIMARY KEY,
    "create_time" date,
    "device_id" bigint ,
    "device_name" varchar(255) ,
    "status" double ,
    "park_id" bigint
) ;

select * from "air"."device_status";
select count(*) from "air"."device_status";


CREATE TABLE "air"."energy_consumption" (
    "id" bigint NOT NULL PRIMARY KEY,
    "created_at" date,
    "park_id" bigint ,
    "unit_energy" double,
    "cooling_pump_energy" double,
    "chilling_pump_energy" double,
    "cooling_tower_energy" double
) ;

select * from "air"."energy_consumption" ;
select count(*) from "air"."energy_consumption";


CREATE TABLE "air"."sensor_data" (
    "id" bigint PRIMARY KEY,
    "created_at" date,
    "park_id" integer ,
    "sensor_id" integer,
    "sensor_name" varchar,
    "collected_data" double,
    "cold_meter_id" integer,
    "cold_meter_real_address" varchar
) ;

select * from "air"."sensor_data" where "sensor_id"=22;
select count(*) from "air"."sensor_data";


CREATE TABLE "air"."summary_data_sum_per_second" (
    "id" bigint PRIMARY KEY ,
    "create_time" date,
    "park_id" integer ,
    "energy_consumption" varchar,
    "energy_consumption_unit" varchar,
    "cooling_capacity" varchar,
    "cooling_capacity_unit" varchar,
    "second_consumption" varchar,
    "second_cooling_capacity" varchar,
    "second_eer" varchar,
    "average_load_rate" varchar,
    "consumptions" varchar,
    "running_current_curve" varchar,
    "water_temperature_curve" varchar
) ;

select * from "air"."summary_data_sum_per_second";
select count(*) from "air"."summary_data_sum_per_second";


CREATE TABLE "air"."summary_data_device_per_second" (
    "id" bigint PRIMARY KEY,
    "create_time" date,
    "park_id" bigint,
    "type_id" bigint,
    "type_name" varchar,
    "device_id" bigint,
    "device_name" varchar,
    "total_active_power" varchar,
    "a_phase_voltage_value" varchar,
    "b_phase_voltage_value" varchar,
    "c_phase_voltage_value" varchar,
    "a_phase_current_value" varchar,
    "b_phase_current_value" varchar,
    "c_phase_current_value" varchar,
    "current_power_consumption" double
);

select * from "air"."summary_data_device_per_second";
select count(*) from "air"."summary_data_device_per_second";

-- 温湿度采集数据表
drop TABLE "air"."temperature_humidity";
CREATE TABLE "air"."temperature_humidity" (
      "id" bigint PRIMARY KEY,
      "created_at" date,
      "park_id" integer ,
      "location_id" integer ,
      "location_name" varchar,
      "temperature" double,
      "humidity" double
) ;

select * from "air"."temperature_humidity";
select count(*) from "air"."temperature_humidity";