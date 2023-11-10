# logstash部署与消费信息传入ES集群

## 部署logstash

```shell
yum -y install logstash.x86_64
```

## 进入/etc/logstash目录，修改logstash.yml文件

```shell
#指定config配置文件目录
path.config: /etc/logstash/conf.d           


#创建conf.d目录和logstash.conf文件
mkdir -p conf.d
#logstash.conf文件配置去kafka消费和传入ES集群
input {
  kafka {
    bootstrap_servers => "192.168.110.26:9092,192.168.110.25:9092,192.168.110.24:9092"  #进入kafka消费
    topics_pattern => "nginx-logs-in-pod-.*" #所要消费的topic下的主题
    codec=>json       #解析json格式、可以根据具体内容生成字段，方便分析和储存。
  }
}

 output {
   elasticsearch {
     hosts => ["192.168.110.26:9200","192.168.110.25:9200","192.168.110.24:9200"]   #传入ES集群
     index => "nginx-%{+YYYY.MM.dd}"    #在ES集群中的名字
   }
}
```

## filebeat配置

ES集群正常配置完，部署`filebeat`

```shell
filebeat.inputs:
- type: log                            # fileststream是从文件中收集日志消息的输入。
  id: nginx                            #在所有输入中唯一的ID，需要输入ID。
  enabled: true                        #更改为true以启用此输入配置。
  paths:
    - /var/log/nginx/access.log        #应该抓取和获取的路径。
    
 
output.kafka:
  hosts: ["192.168.110.26:9092","192.168.110.25:9092","192.168.110.24:9092"]    #要连接的主机阵列
  topic: nginx-logs-in-pod-%{+YYYY.MM.dd}                         #topic主题名
  partition.round_robin:
    reachable_only: true
  required_acks: 1
  compression: gzip                                               #压缩
  max_message_bytes: 1000000                                      #最大字节数
```

kafka正常配置



### 默认Logstash不保证事件顺序，重新排序可以发送在两个地方：

- 批处理中的事件可以在过滤器处理期间重新排序
- 当一个或多个批次的处理速度快于其他批次时，可以对批次重新排序

### 当维护事件顺序非常重要时，排序设置：

1. 设置`pipeline.ordered: auto`且设置`pipeline.workers: 1`，则自动启用排序。
2. 设置`pipeline.ordered: true`，这种方法可以确保批处理是一个一个的执行，并确保确保事件在批处理中保持其顺序。
3. 设置`pipeline.ordered: false`则禁用排序处理，但可以节省排序所需的成本。

## logstash插件

```shell
#在input和output之间插入过滤

filter {        
  grok {        #grok过滤插件模式的语法 %{SYNTAX:SEMAANTIC}      SYNTAX代表匹配值的类型，SEMANTIC代表赋值字段名称     
    match => {
      "message" => '%{IP:remote_addr} - (%{WORD:remote_user}|-) \[%{HTTPDATE:time_local}\] "%{WORD:method} %{NOTSPACE: request} HTTP/%{NUMBER}" %{NUMBER:status} %{NUMBER:body_bytes_sent} %{QS} %{QS:http_user_agent}'
    }
    remove_field => "message"
  }
  date {        #date插件 过滤用于解析字段中的日期，然后使用该日期或时间戳作为时间的logstash时间戳
    match => ["time", "dd/MMM/yyyy:HH:mm:ss Z"]
    target => "@timestamp"
    remove_field => "time"
  }
}
```



