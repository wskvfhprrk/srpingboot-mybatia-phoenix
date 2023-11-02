#!/bin/bash
#此脚本运行前提时必须实现免密登陆和服务器间数据传送,使用的是root用户
#备份文件路径：
back_path=/root/back
base_path=/opt/soft
#jdk安装路径
jdk_path=$base_path/jdk1.8.0_381
#hadoop路径
hadoop_path=$base_path/hadoop-3.1.3
#hbase安装路径
hbase_path=$base_path/hbase
#zookeeper安装路径
zk_path=$base_path/zk
#服务器hostname
servers=("hd37" "hd38" "hd39")
# 检查第一个参数是否存在
if [ -z "$1" ]; then
    echo "缺少参数，退出程序。"
    exit 1
fi
if [ $1 = 2 ]; then
  echo "装新系统，所有数据将删除！"
elif [ $1 = 1 ]; then
  echo "执行重装，原数据将保存！"
fi
echo =========== 停止hadoop    ========================
/root/stop.sh
echo =========== 删除soft文件夹 =========================
for server in "${servers[@]}"
do
    echo "$server 删除soft文件夹"
    ssh root@$server "rm -rf $base_path/"
done
echo =========== 拷贝环境变量   =========================
for server in "${servers[@]}"
do
    ssh root@$server "rpm -qa | grep java"
    echo "$server 的环境变量"
    scp -r $back_path/path/my_dev.sh root@$server:/etc/profile.d/
    ssh root@$server "source /etc/profile"
done
echo =========== soft文件夹新建 =========================
for server in "${servers[@]}"
do
    echo "$server soft文件夹新建"
    ssh root@$server "mkdir -p  $base_path/"
done
echo =========== jdk安装新的jkd =========================
cp -r jdk1.8.0_381/ $base_path/
echo =========== 安装hadoop    =========================
tar -xzf hadoop-3.1.3.tar.gz -C $base_path/
echo =========== 安装hbase     =========================
tar -xzf hbase-2.4.17-bin.tar.gz -C $base_path/
echo =========== 安装zk        =========================
tar -xzf apache-zookeeper-3.8.3-bin.tar.gz -C $base_path/
echo =========== 改文件名称     =========================
mv $base_path/apache-zookeeper-3.8.3-bin $zk_path
mv $hbase_path-2.4.17 $hbase_path
echo =========== hadoop配置    =========================
rm -rf $hadoop_path/etc/hadoop/core-site.xml
cp -rf $back_path/hadoop/etc/hadoop/core-site.xml $hadoop_path/etc/hadoop/

rm -rf $hadoop_path/etc/hadoop/hdfs-site.xml
cp -rf $back_path/hadoop/etc/hadoop/hdfs-site.xml $hadoop_path/etc/hadoop/

rm -rf $hadoop_path/etc/hadoop/mapred-site.xml
cp -rf $back_path/hadoop/etc/hadoop/mapred-site.xml $hadoop_path/etc/hadoop/

rm -rf $hadoop_path/etc/hadoop/yarn-site.xml
cp -rf $back_path/hadoop/etc/hadoop/yarn-site.xml $hadoop_path/etc/hadoop/

rm -rf $hadoop_path/etc/hadoop/workers
cp -rf $back_path/hadoop/etc/hadoop/workers $hadoop_path/etc/hadoop/

rm -rf $hadoop_path/etc/hadoop/hadoop-env.sh
cp -rf $back_path/hadoop/etc/hadoop/hadoop-env.sh $hadoop_path/etc/hadoop/

rm -rf $hadoop_path/sbin/start-dfs.sh
cp -rf $back_path/hadoop/sbin/start-dfs.sh $hadoop_path/sbin/

rm -rf $hadoop_path/sbin/stop-dfs.sh
cp -rf $back_path/hadoop/sbin/stop-dfs.sh $hadoop_path/sbin/

rm -rf $hadoop_path/sbin/start-yarn.sh
cp -rf $back_path/hadoop/sbin/start-yarn.sh $hadoop_path/sbin/

rm -rf $hadoop_path/sbin/stop-yarn.sh
cp -rf $back_path/hadoop/sbin/stop-yarn.sh $hadoop_path/sbin/

echo =========== zk配置        =========================
cp $back_path/zk/conf/zoo.cfg $zk_path/conf/
echo =========== 复制soft      =========================
cp  -rf $back_path/soft/* $base_path/
echo =========== hbase配置     =========================

rm -rf $hbase_path/conf/hbase-env.sh
cp -rf $back_path/hbase/conf/hbase-env.sh $hbase_path/conf/

rm -rf $hbase_path/conf/hbase-site.xml
cp -rf $back_path/hbase/conf/hbase-site.xml $hbase_path/conf/

rm -rf $hbase_path/conf/regionservers
cp -rf $back_path/hbase/conf/regionservers $hbase_path/conf/
echo =========== 解决日志冲突   =========================
mv $hbase_path/lib/client-facing-thirdparty/slf4j-reload4j-1.7.33.jar $hbase_path/lib/client-facing-thirdparty/slf4j-reload4j-1.7.33.jar.bak
echo =========== HMaster高可用 =========================
echo "hd38" > $hbase_path/conf/backup-masters
echo =========== phoniex      =========================
tar -xzf phoenix-hbase-2.4.0-5.1.3-bin.tar.gz -C $base_path/
mv $base_path/phoenix-hbase-2.4.0-5.1.3-bin/ $base_path/phoenix
cp $base_path/phoenix/phoenix-server-hbase-2.4.0.jar $hbase_path/lib/
echo =========== 分发文件      =========================
./xsync.sh $jdk_path
./xsync.sh $hadoop_path
./xsync.sh $zk_path
./xsync.sh $hbase_path
if [ $1 = 2 ]; then
    # 在这里写下面的程序

    for server in "${servers[@]}"
    do
        echo "$server 删除hadoop"
        ssh root@$server "rm -rf /opt/hadoop"
    done
    for server in "${servers[@]}"
    do
        echo "$server 删除hbase"
        ssh root@$server "rm -rf /opt/hbase"
    done
    #修改zk下的myid
    i=0
    for server in "${servers[@]}"
    do
        echo "$server 删除zk并重置myid"
        ssh root@$server "rm -rf  /opt/zk/"
        ssh root@$server "mkdir -p /opt/zk/zkData/"
        i=$((i + 1))
        ssh root@$server "echo $i > /opt/zk/zkData/myid"
    done
    $hadoop_path/bin/hdfs namenode -format
elif [ $1 = 1 ]; then
    echo "执行重装,原数据将保存！"
fi
for server in "${servers[@]}"
    do
        echo "$server 清空缓存文件"
        ssh root@$server "rm -rf  /tmp/*"
    done
echo =========== 启动hadoop   ==========================
$base_path/hdp.sh start
$zk_path.sh start
$hbase_path/bin/start-hbase.sh
./jpsall
rm -rf .sqlline
$base_path/phoenix/bin/sqlline.py hd37,hd38,hd39:2181
