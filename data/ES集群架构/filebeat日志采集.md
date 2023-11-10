



# filebeat日志采集

## 1.采用二进制安装，方法如下

上传二进制安装包到宿主机并解压缩

```shell
tar zxf filebeat-7.17.7-linux-x86_64.tar.gz -C /usr/local/ #解压缩并指定目
录
# 将二进制文件转移到环境变量目录
mv filebeat /usr/bin
# 查看帮助信息
filebeat -h

```

## 1.2启动方案

```shell
# 直接使用不间断后台启动模式
nohup filebeat -e -c /<配置文件路径> &
```

### 1.2.1验证配置

**输入为log，输出为console**

真正生产不用使用这个输出，这个输出类型可以作为开发、测试调试用，通过这个案例可以看清经过filebeat处理的日志文件会变成什么样子。

**首先做准备工作：**
```shell
# 创建第一个文件夹
mkdir 01-console
cd 01-console
# 创建两个文件，第一个log是日志(也就是数据收集的目标文件)，第二个yaml是filebeat配置文件
touch csb.log 01-console.yml
```
**将csb.log中输入内容：**
```shell
echo "先帝创业未半而中道崩殂" > csb.log
echo "今天下三分" >> csb.log
```
**编辑filebeat配置文件：**
```shell
#要采集的日志
filebeat.inputs:
- type: log #输入类型(输入格式)
paths: #路径，类型为列表，推荐绝对路径
- /root/01-console/csb.log #csb.log所存放的路径
#要上传到地点
output.elasticsearch: # 下面hosts如果固定可以使用IP，如果使用域名必须在/etc/hosts有解
析
hosts: ["http://172.27.11.100:9200"]
index: "zhangqiang-%{+yyyy.MM.dd}" #索引名字

#定义上传的索引名字
setup.ilm.enabled: false # 禁用ILM
setup.template.name: "zhangqiang" # 自定义索引名称前缀
setup.template.pattern: "zhangqiang*" # 自定义索引名匹配模式(别名模式)
setup.template.overwrite: true
```

**1.3启动filebeat，指定配置文件：**

```shell
filebeat -e -c /root/01-console/01-console.yml
```

最后到kibana上查看索引

![索引管理](D:\Typora\文件图片\索引管理.jpg)


## 2.yum安装filebeat日志采集

### 2.1 yum源下载filebeat

```shell
yum -y install filebeat
```

### 2.2更改配置

**修改/etc/filebeat/filebeat.yml文件**

```shell
- type: filestream
id: nginx-log
enabled: true
paths:
- /var/log/messages
fields_under_root: true
fields:
type: system
#匹配不同的日志创建不同的索引
- type: filestream
id: yum-log
enabled: true
paths:
- /var/log/yum.log
fields_under_root: true
fields:
type: yum
#以上为采集

#以下为上传kibana并创建索引
output.elasticsearch:
# Array of hosts to connect to.
hosts: ["192.168.110.26:9200"]
indices:
- index: "syslog-log-%{+yyyy.MM.dd}"
when.equals:
type: "system"
- index: "yumlog-log-%{+yyyy.MM.dd}"
when.equals:
type: "yum"
```
### 2.3最后启动
```shell
systemctl start filebeat
```
### !!!日志采集启动后被采集日志有变动后才会自动创建索引

## 采集日志格式为json格式,以nginx日志为例：

```shell
#    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
#                      '$status $body_bytes_sent "$http_referer" '
#                      '"$http_user_agent" "$http_x_forwarded_for"';    #$http_x_forwarded_for作用 获取前端真实服务器地址

#修改日志格式为json格式，
log_format log_json '{"@timestamp": "$time_local", '
                        '"remote_addr": "$remote_addr", '
                        '"referer": "$http_referer", '
                        '"request": "$request", '
                        '"status": $status, '
                        '"bytes": $body_bytes_sent, '
                        '"agent": "$http_user_agent", '
                        '"x_forwarded": "$http_x_forwarded_for", '
                        '"up_addr": "$upstream_addr",'
                        '"up_host": "$upstream_http_host",'
                        '"up_resp_time": "$upstream_response_time",'
                        '"request_time": "$request_time"'
                        ' }';
    # 引用日志
    access_log  /var/log/nginx/access.log  log_json;
```

```shell
- type: log
  id: nginx
  enabled: true
  paths:
    - /var/log/nginx/access.log  
    
  json:
    keys_under_root: true        #可以让字段位于根节点，默认为false
    overwrite_keys: true         #对于同名的key，覆盖原有的key值
    add_error_key: true          #将解析错误的消息记录存储在error.message字段中
    message_key: "message"       #用来合并多行json日志使用

```



![日志格式](D:\Typora\文件图片\日志格式.jpg)



## filebeat模块采集方式

在/etc/filebeat/modules.d目录下可以看到很多模块，如何启用这些模块

![modules采集模块](D:\Typora\文件图片\modules采集模块.jpg)

需要先把filebeat.inputs中采集信息注释掉



然后写入modules的路径

```shell
filebeat.config.modules:
  # Glob pattern for configuration loading
  path: /etc/filebeat/modules.d/*.yml

  # Set to true to enable config reloading
  reload.enabled: false
```

最后启用需要的模块，例如启用nginx：

```shell
filebeat modules enable nginx
```

**默认配置即可，若不开启error则true改为false**

![image-20231026193534350](C:\Users\92574\AppData\Roaming\Typora\typora-user-images\image-20231026193534350.png)

最后重启filebeat

```shell
systemctl restart filebeat.service
```

```shell
nginx -s reopen   #nginx重新加载
```



### filebeat多行日志的处理

```shell
multiline:                                        #多行日志合并
    type: pattern                      #模式
    pattern: '^[[:space:]]'            #表示已空格开头的行
    negate: false                      #true表示开启取反
    match: after                       #接在.....之后
```

![多行合并](D:\Typora\文件图片\多行合并.jpg)



![多行日志匹配规则](D:\Typora\文件图片\多行日志匹配规则.jpg)

### 匹配开头和结尾的部分内容

```shell
filebeat.inputs:
- type: log
  paths:
    - /root/difflogs/09-event/event.log
  multiline:
    type: pattern
    pattern: 'Start new event'   # 这里是匹配行的开始，但是end结尾没有处理办法，如何采用截断方法？
    negate: true          # 是否否决多行匹配吗？选择true，也就是说多行不匹配添加到匹配行后面就好了 
    match: after
    flush_pattern: 'End event'   # 这个专门用于解决匹配时间最后的终止行应该具备什么，加上就可以了

output.elasticsearch:
  hosts: ["http://elasticstack1:9200","http://elasticstack2:9200","http://elasticstack3:9200"]
  index: "event-%{+yyyy.MM.dd}"

setup.ilm.enabled: false
setup.template.name: "event"
setup.template.pattern: "event*"
```







```shell
#采集
filebeat.inputs:
- type: log
  id: my-filestream-id
  enabled: true
  paths:
    - /var/log/access.log

#上传ES
output.elasticsearch:
  hosts: ["192.168.110.26:9200"]
  indices:
  - index: "nginx-log-%{+yyyy.MM.dd}"


#采集
filebeat.inputs:
- type: log
  paths:
    - /var/log/nginx/access.log
#上传按字段区分
output.elasticsearch:
  hosts: ["http://elasticstack1:9200"]
  indices:
    - index: "ret-code-200-%{+yyyy.MM.dd}"     
      when.contains:                               
        message: " 200 "                  # 如果message字段包含200，那么就把日志扔到200索引中
    - index: "ret-code-304-%{+yyyy.MM.dd}"
      when.contains:
        message: " 304 "                  # 如果message字段包含304，那么就把日志扔到304索引中
    - index: "ret-code-404-%{+yyyy.MM.dd}"
      when.contains:
        message: " 404 "                  # 如果message字段包含404，那么就把日志扔到404索引中
   
setup.ilm.enabled: false                          
setup.template.name: "ret-code"                   
setup.template.pattern: "ret-code*"


#多行日志合并
filebeat.inputs:
  multiline:                                        
    type: pattern                      #模式
    pattern: '^[[:space:]]'            #表示已空格开头的行
    negate: false                      #true表示开启取反
    match: after

#发送到kafka
output.kafka:
  hosts: ["192.168.110.26:9092","192.168.110.25:9092","192.168.110.24:9092"]    #要连接的主机阵列
  topic: nginx-logs-in-pod-%{+YYYY.MM.dd}                         #topic主题名
  partition.round_robin:
    reachable_only: true
  required_acks: 1
  compression: gzip                                               #压缩
  max_message_bytes: 1000000

#指定索引分片和副本
setup.template.settings:
    index.number_of_shards: 3
    index.number_of_replicas: 1
setup.template.name: "nginx-log-%{+yyyy.MM.dd}"
setup.template.pattern: "nginx-log-%{+yyyy.MM.dd}"
setup.ilm.enabled: false


```



