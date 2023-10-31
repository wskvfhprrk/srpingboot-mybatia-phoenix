#!/bin/bash
#备份文件路径：
back_path=/root/back
base_path=/opt/soft
jdk_path=$base_path


echo =========== 停止hadoop============================
/root/stop.sh

echo =========== 删除hd38,hd39 soft文件夹重新建===========
ssh root@hd38 "rm -rf $base_path/"
ssh root@hd38 "mkdir -p  $base_path/"
ssh root@hd39 "rm -rf $base_path/"
ssh root@hd39 "mkdir -p  $base_path/"
# 继续执行其他命令
echo "hd38，hd39文件夹已清空，继续执行其他操作..."
echo 进入备份文件目录
echo =========== 拷贝环境变量文件,把文件拷到/etc/profile.d/目录下===========
rm -rf /etc/profile.d/my_dev.sh
cp -r $back_path/path/* /etc/profile.d/
echo =========== 删除所有环境变量 ===========
rpm -qa | grep java
rpm -qa | grep hadoop
rpm -qa | grep hbase
rpm -qa | grep zookeeper
echo =========== 删除soft文件夹重新建==================================
rm -rf $base_path/
mkdir -p  $base_path/
echo =========== jdk安装新的jkd==================================
cp -r jdk1.8.0_381/ $base_path/
echo =========== hadoop安装新的hadoop============================
tar -xzf hadoop-3.1.3.tar.gz -C $base_path/
echo =========== hbase安装新的hbase============================
tar -xzf hbase-2.4.17-bin.tar.gz -C $base_path/
echo =========== zk安装新的zk============================
tar -xzf apache-zookeeper-3.8.3-bin.tar.gz -C $base_path/
echo =========== 改名称============================
mv $base_path/apache-zookeeper-3.8.3-bin $base_path/zk
mv $base_path/hbase-2.4.17 $base_path/hbase
echo =========== hadoop配置============================
rm -rf $base_path/hadoop-3.1.3/etc/hadoop/core-site.xml
cp -rf $back_path/hadoop/etc/hadoop/core-site.xml $base_path/hadoop-3.1.3/etc/hadoop/

rm -rf $base_path/hadoop-3.1.3/etc/hadoop/hdfs-site.xml
cp -rf $back_path/hadoop/etc/hadoop/hdfs-site.xml $base_path/hadoop-3.1.3/etc/hadoop/

rm -rf $base_path/hadoop-3.1.3/etc/hadoop/mapred-site.xml
cp -rf $back_path/hadoop/etc/hadoop/mapred-site.xml $base_path/hadoop-3.1.3/etc/hadoop/

rm -rf $base_path/hadoop-3.1.3/etc/hadoop/yarn-site.xml
cp -rf $back_path/hadoop/etc/hadoop/yarn-site.xml $base_path/hadoop-3.1.3/etc/hadoop/

rm -rf $base_path/hadoop-3.1.3/etc/hadoop/workers
cp -rf $back_path/hadoop/etc/hadoop/workers $base_path/hadoop-3.1.3/etc/hadoop/

rm -rf $base_path/hadoop-3.1.3/etc/hadoop/hadoop-env.sh
cp -rf $back_path/hadoop/etc/hadoop/hadoop-env.sh $base_path/hadoop-3.1.3/etc/hadoop/

rm -rf $base_path/hadoop-3.1.3/sbin/start-dfs.sh
cp -rf $back_path/hadoop/sbin/start-dfs.sh $base_path/hadoop-3.1.3/sbin/

rm -rf $base_path/hadoop-3.1.3/sbin/stop-dfs.sh
cp -rf $back_path/hadoop/sbin/stop-dfs.sh $base_path/hadoop-3.1.3/sbin/

rm -rf $base_path/hadoop-3.1.3/sbin/start-yarn.sh
cp -rf $back_path/hadoop/sbin/start-yarn.sh $base_path/hadoop-3.1.3/sbin/

rm -rf $base_path/hadoop-3.1.3/sbin/stop-yarn.sh
cp -rf $back_path/hadoop/sbin/stop-yarn.sh $base_path/hadoop-3.1.3/sbin/

echo =========== zk配置============================
cp $back_path/zk/conf/zoo.cfg $base_path/zk/conf/
mkdir -p $base_path/zk/zkData
cp -r $back_path/zk/zkData/myid $base_path/zk/zkData/
echo =========== 脚本文件复制soft============================
cp  -rf $back_path/soft/* $base_path/
echo =========== hbase配置============================

rm -rf $base_path/hbase/conf/hbase-env.sh
cp -rf $back_path/hbase/conf/hbase-env.sh $base_path/hbase/conf/

rm -rf $base_path/hbase/conf/hbase-site.xml
cp -rf $back_path/hbase/conf/hbase-site.xml $base_path/hbase/conf/

rm -rf $base_path/hbase/conf/regionservers
cp -rf $back_path/hbase/conf/regionservers $base_path/hbase/conf/
echo =========== 解决hbase与hadoop日志冲突============================
mv $base_path/hbase/lib/client-facing-thirdparty/slf4j-reload4j-1.7.33.jar $base_path/hbase/lib/client-facing-thirdparty/slf4j-reload4j-1.7.33.jar.bak
echo =========== HMaster高可用============================
echo "hd38" > $base_path/hbase/conf/backup-masters
echo =========== phoniex============================
tar -xzf phoenix-hbase-2.4.0-5.1.3-bin.tar.gz -C $base_path/
mv $base_path/phoenix-hbase-2.4.0-5.1.3-bin/ $base_path/phoenix
cp $base_path/phoenix/phoenix-server-hbase-2.4.0.jar $base_path/hbase/lib/
echo =========== 分发文件============================
./xsync.sh $base_path/hadoop-3.1.3/
./xsync.sh $base_path/zk/
./xsync.sh $base_path/hbase/
echo =========== 修改zk下的myid============================
ssh root@hd38 "sed -i 's/1/2/g' $base_path/zk/zkData/myid"
ssh root@hd39 "sed -i 's/1/3/g' $base_path/zk/zkData/myid"
echo =========== 刷新运行环境变量========================================
source /etc/profile
ssh root@hd38 "source /etc/profile"
ssh root@hd39 "source /etc/profile"
echo =========== 格式化hdfs============================
format_command=$"$base_path/hadoop-3.1.3/bin/hdfs namenode -format"
echo "是否执行格式化hdfs程序？如果执行，所有数据将删除 (y/n)"
read input
if [ "$input" = "y" ]; then
    # 在这里写下面的程序
    echo "执行格式化hdfs程序………………………………………………"
    rm -rf /opt/hadoopData
    ssh root@hd38 "rm -rf /opt/hadoopData"
    ssh root@hd39 "rm -rf /opt/hadoopData"
    eval "$format_command"
else
    echo "取消执行"
fi
echo =========== 启动hadoop============================
$base_path/hdp.sh start
$base_path/zk.sh start
$base_path/hbase/bin/start-hbase.sh
./jpsall
rm -rf .sqlline
$base_path/phoenix/bin/sqlline.py hd37,hd38,hd39:2181
