# 部署zookeeper(集群)和kafka

## 1.部署zookeeper

### 上传 apache-zookeeper-3.8.3-bin.tar.gz安装包并解压缩

```shell
tar zxf apache-zookeeper-3.8.3-bin.tar.gz /usr/local/
```

### 创建zookeeper的数据目录

```shell
mkdir -p /var/lib/zookeeper
```

### 创建zookeeper的配置文件在conf/zoo.cfg

```shell
tickTime=1000
dataDir=/var/lib/zookeeper
clientPort=2181
initLimit=30
syncLimit=10
server.1=192.168.112.128:2888:3888
server.2=192.168.112.129:2888:3888
server.3=192.168.112.130:2888:3888
```

### 在集群所有服务器中创建myid文件，分别写入id不要重复

```shell
# kafka-broker1
echo 1 > /var/lib/zookeeper/myid
# kafka-broker2
echo 2 > /var/lib/zookeeper/myid
# kafka-broker3
echo 3 > /var/lib/zookeeper/myid
```

### 启动集群服务器让其完成集群的构建

```shell
< 路径 >/./zkServer.sh start  #启动    stop停止     restart重启    status查看集群状态  
#也可以使用telnet
telnet <ip> 2181 
srvr     #在阻塞位置输入srvr 
```

## 2.kafka布置

​		Kafka是一种高吞吐量的分布式发布订阅消息系统，它可以处理消费者在网站中的所有动作流数据。其核心组件包含Producer、Broker、Consumer，以及依赖的Zookeeper集群。其中Zookeeper集群是Kafka用来负责集群元数据的管理、控制器的选举等。

### 特性

**高吞吐量、低延迟**

​		Kafka 每秒可以处理几十万条消息，它的延迟最低只有几毫秒。每个 topic 可以分多个 Partition，Consumer Group 对 Partition 进行消费操作，提高负载均衡能力和消费能力。

**可扩展性**

​		kafka 集群支持热扩展。

**持久性、可靠性**

​		消息被持久化到本地磁盘，并且支持数据备份防止数据丢失。

**容错性**

​		允许集群中节点失败（多副本情况下，若副本数量为 n，则允许 n-1 个节点失败）。

**高并发**

​		支持数千个客户端同时读写。

### 组件及概念

**Broker**（工作节点或工作实例：一个节点一个Broker）
		一台 kafka 服务器就是一个 broker。一个集群由多个 broker 组成。一个 broker 可以容纳多个 topic。

**Topic**（主题，写入存储）
		可以理解为一个队列，生产者和消费者面向的都是一个 topic，类似于数据库的表名或者 ES 的 index物理上不同 topic 的消息分开存储。

**Partition**（分区，保证数据的完整性）
		为了实现扩展性，一个非常大的 topic 可以分布到多个 broker（即服务器）上，一个 topic 可以分割为一个或多个 partition，每个 partition 是一个有序的队列。Kafka 只保证 partition 内的记录是有序的，而不保证 topic 中不同 partition 的顺序。

​		每个 topic 至少有一个 partition，当生产者产生数据的时候，会根据分配策略选择分区，然后将消息追加到指定的分区的队列末尾。

## 上传kafka_2.13-3.6.0.tgz包并解压

```shell
tar zxf kafka_2.13-3.6.0.tgz
```

## 进入kafka配置文件更改配置

```shell
#三台分别为1，2，3
broker.id=1(2,3)

#下面内容固定
zookeeper.connect=192.168.110.26:2181,192.168.110.25:2181,192.168.110.24:2181
```

## 创建kafka日志目录

```shell
 mkdir -p /tmp/kafka-logs
```

## 启动kafka

```shell
./kafka-server-start.sh -daemon /root/kafka_2.13-3.6.0/config/server.properties
```

## 查看端口是否启动成功

```shell 
ss -ntl #kafka端口 9092
```

## jps查看线程需要安装jps

```shell
 yum -y install java-1.8.0-openjdk-devel.x86_64     
 jps        #下载完后直接查看
```



### kafka在0.5.x版本后自带zookeeper不用再单独部署zookeeper，部署方法如下：

```shell
#解压
tar zxf kafka_2.13-3.6.0.tgz
#进入config修改zookeeper.properties
 cd /usr/local/kafka_2.13-3.6.0/config/
 vim zookeeper.properties
 #添加以下参数
initLimit=10     #初始通信时限
syncLimit=5      #同步通信时限
server.1=192.168.110.26:2888:3888
server.2=192.168.110.25:2888:3888
server.3=192.168.110.24:2888:3888
```

### 启动zookeeper和kafka

```shell
./zookeeper-server-start.sh -daemon ../config/zookeeper.properties
./kafka-server-start.sh -daemon ../config/server.properties    
#启动命令根据所在路径不同，进行修改
```

#### 新建topic

```shell
./bin/kafka-topics.sh --create --bootstrap-server 192.168.110.26:9092 --partitions 3 --replication-factor 2 --topic bwwg 
```

#### 查看

```shell
./kafka-topics.sh --bootstrap-server 192.168.110.26:9092 --describe --topic bwwg   #查看bwwg详情
./kafka-topics.sh --bootstrap-server 192.168.110.26:9092 --list   #查看有多少个topic
```

#### 增加topic分区

``` shell
./kafka-topics.sh --bootstrap-server 192.168.110.26:9092 --alter --partitions 6 --topic bwwg
```

### 修改一个topic的副本数

```shell
#创建一个topic名为bwwg，指定分区为2，副本为1
# ./bin/kafka-topics.sh --bootstrap-server 192.168.110.26:9092 --create --replication-factor 1 --partitions 2 --topic bwwg1
Created topic bwwg.

#查看新创建的topic详细信息
# ./bin/kafka-topics.sh --bootstrap-server 192.168.110.26:9092 --describe --topic bwwg1
Topic:bwwg1     PartitionCount:2        ReplicationFactor:1     Configs:
        Topic: bwwg1    Partition: 0    Leader: 0       Replicas: 0     Isr: 0
        Topic: bwwg1    Partition: 1    Leader: 1       Replicas: 1     Isr: 1

#将broker.id为0上的partition的副本由原来的[0]扩充为[0,2]，将broker.id为1上的partition的副本由原来的[1]扩充为[1,2]。
#需要先创建一个json文件如下：
# cat partitions-to-move.json
{
    "partitions":
    [
        {
            "topic":"bwwg",   #主题名字
            "partition": 0,   #分区号
            "replicas": [1,2] #副本数
        },
        {
            "topic": "bwwg",
            "partition": 1,
            "replicas": [1,2]
        }
    ],
    "version": 1
}
#执行修改命令
./bin/kafka-reassign-partitions.sh --bootstrap-server 192.168.110.26:9092 --reassignment-json-file ./config/partitions-to-move.json --execute
```

### 生产者传入

```shell
./kafka-console-producer.sh --broker-list 192.168.110.26:9092 --topic <主题名字> kafka-test
>666
```

### 消费者查看

```shell
./kafka-console-consumer.sh --bootstrap-server 192.168.110.26:9092 --from-beginning --topic <主题名字> kafka-test               #--from-beginning主题中所有的数据都读取出来
666


./kafka-console-consumer.sh --bootstrap-server 192.168.110.26:9092  --topic <主题名字> kafka-tes  #同步接收（监听状态）
```









