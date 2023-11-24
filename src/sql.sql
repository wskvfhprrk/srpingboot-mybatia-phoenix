-- user测试数据
drop TABLE "user";
CREATE TABLE "user"
(
    "id"   bigint NOT NULL PRIMARY KEY,
    "name" varchar,
    "age"  integer,
    "sex"  varchar,
    "date" TIMESTAMP
);

upsert
into "user" values (1,'张三',18,'男','2023-08-12 00:00:01');
upsert
into "user" values (2,'李四',18,'男','2023-05-12 12:12:50');

select *
from "user";
select SUM("age")
from "user";
select AVG("age")
from "user";
-- pheneix创建表——与mysql字段对应
delete from "air"."data_device_original";
drop TABLE "air"."data_device_original";
CREATE TABLE "air"."data_device_original"
(
    "id"          bigint NOT NULL PRIMARY KEY,
    "topic"       varchar(255),
    "create_time" TIMESTAMP,
    "content"     VARBINARY
);

select * from "air"."data_device_original" order by "create_time" desc;
select count (*) from "air"."data_device_original";
select MAX ("create_time") from "air"."data_device_original";
select MAX ("id") from "air"."data_device_original";
select * from "air"."data_device_original" where "id"=(select MAX ("id") from "air"."data_device_original");
-- 同步原始数据表
drop TABLE "air"."data_power";
CREATE TABLE "air"."data_power"
(
    "id"          bigint NOT NULL PRIMARY KEY,
    "create_time" TIMESTAMP,
    "park_id"     bigint,
    "type_id"     bigint,
    "device_id"   bigint,
    "device_name" varchar(255),
    "power"       bigint
);
select *
from "air"."data_power";
select count(*)
from "air"."data_power";
SELECT
    TO_CHAR(MIN("create_time"), 'YYYY-MM') as month,
  MAX("power") - MIN("power") as daily_power_usage
FROM
    "air"."data_power"
GROUP BY
    TO_CHAR("create_time", 'YYYY-MM');
SELECT
    TO_CHAR(MIN("create_time"), 'yyyy-MM-dd') as day,
  MAX("power") - MIN("power") as daily_power_usage
FROM
    "air"."data_power"
GROUP BY
    TO_CHAR("create_time", 'yyyy-MM-dd');


select * from "air"."data_power" where "id"=(select MAX ("id") from "air"."data_power");
SELECT
    TO_CHAR("create_time", 'YYYY-MM') AS "month",
    MAX("power") AS "max_power",
    MIN("power") AS "min_power",
    MAX("power") - MIN("power") AS "power_difference"
FROM
    "air"."data_power"
where "device_id"=2 and "power"<>0
GROUP BY
    TO_CHAR("create_time", 'YYYY-MM')
ORDER BY
    "month";
select *
from "air"."data_power"
where "device_id" = 4;
select *
from "air"."data_power"
where "device_id" = 4
  and "create_time" > TO_DATE('2023-08-01', 'yyyy-MM-dd');
select MIN(TO_NUMBER("power")) as min ,MAX (TO_NUMBER("power")) as max
from "air"."data_power";
where "device_id"=4 and "create_time" > TO_DATE('2023-08-01', 'yyyy-MM-dd');
select *
from "air"."data_power"
where "device_id" = 2
  and "create_time" > TO_TIMESTAMP('2023-08-01 12:34:56', 'yyyy-MM-dd HH:mm:ss');;
select count(*)
from "air"."data_power";

drop TABLE "air"."device_status";
CREATE TABLE "air"."device_status"
(
    "id"          bigint NOT NULL PRIMARY KEY,
    "create_time" TIMESTAMP,
    "device_id"   bigint,
    "device_name" varchar(255),
    "status"      double,
    "park_id"     bigint
);

select "id",SUBSTR(to_char("create_time"),1,10)
from "air"."device_status";
select count(*)
from "air"."device_status";


CREATE TABLE "air"."energy_consumption"
(
    "id"                   bigint NOT NULL PRIMARY KEY,
    "created_at"           TIMESTAMP,
    "park_id"              bigint,
    "unit_energy"          double,
    "cooling_pump_energy"  double,
    "chilling_pump_energy" double,
    "cooling_tower_energy" double
);

select *
from "air"."energy_consumption";
select count(*)
from "air"."energy_consumption";
select * from "air"."energy_consumption" where "id"=(select MAX ("id") from "air"."energy_consumption");

CREATE TABLE "air"."sensor_data"
(
    "id"                      bigint PRIMARY KEY,
    "created_at"              TIMESTAMP,
    "park_id"                 integer,
    "sensor_id"               integer,
    "sensor_name"             varchar,
    "collected_data"          double,
    "cold_meter_id"           integer,
    "cold_meter_real_address" varchar
);

select *
from "air"."sensor_data"
where "sensor_id" = 22;
select count(*)
from "air"."sensor_data";
select * from "air"."sensor_data" where "created_at"=(select MAX ("created_at") from "air"."sensor_data");


CREATE TABLE "air"."summary_data_sum_per_second"
(
    "id"                      bigint PRIMARY KEY,
    "create_time"             TIMESTAMP,
    "park_id"                 integer,
    "energy_consumption"      varchar,
    "energy_consumption_unit" varchar,
    "cooling_capacity"        varchar,
    "cooling_capacity_unit"   varchar,
    "second_consumption"      varchar,
    "second_cooling_capacity" varchar,
    "second_eer"              varchar,
    "average_load_rate"       varchar,
    "consumptions"            varchar,
    "running_current_curve"   varchar,
    "water_temperature_curve" varchar
);

select *
from "air"."summary_data_sum_per_second";
select count(*)
from "air"."summary_data_sum_per_second";
select * from "air"."summary_data_sum_per_second" where "id"=(select MAX ("id") from "air"."summary_data_sum_per_second");

CREATE TABLE "air"."summary_data_device_per_second"
(
    "id"                        bigint PRIMARY KEY,
    "create_time"               TIMESTAMP,
    "park_id"                   bigint,
    "type_id"                   bigint,
    "type_name"                 varchar,
    "device_id"                 bigint,
    "device_name"               varchar,
    "total_active_power"        varchar,
    "a_phase_voltage_value"     varchar,
    "b_phase_voltage_value"     varchar,
    "c_phase_voltage_value"     varchar,
    "a_phase_current_value"     varchar,
    "b_phase_current_value"     varchar,
    "c_phase_current_value"     varchar,
    "current_power_consumption" double
);

select *
from "air"."summary_data_device_per_second";
select count(*)
from "air"."summary_data_device_per_second";

-- 温湿度采集数据表
drop TABLE "air"."temperature_humidity";
CREATE TABLE "air"."temperature_humidity"
(
    "id"            bigint PRIMARY KEY,
    "created_at"    TIMESTAMP,
    "park_id"       integer,
    "location_id"   integer,
    "location_name" varchar,
    "temperature"   double,
    "humidity"      double
);

select *
from "air"."temperature_humidity";
select count(*)
from "air"."temperature_humidity";