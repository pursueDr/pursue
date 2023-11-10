# ES部署流程 #

## 1.1 上传elasticsearch.repo源码包

 **elasticsearch.repo源码包上传到虚拟机/etc/yum.repos.d目录下**

```shell
yum -y install elasticsearch #安装elasticsearch
```

## 1.2 导入密钥

```shell
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```



## 1.3配置文件修改 

```shell
sed -n '/^[^#]/p' /etc/elasticsearch/elasticsearch.yml     #屏蔽输出-n 不已#号开头的所有行
#vim打开/etc/elasticsearch/elasticsearch.yml文件
cluster.name: my-es   				#集群名字
node.name: es1        				#节点名字
path.data: /var/lib/elasticsearch	 #数据存放位置
path.logs: /var/log/elasticsearch    #日志存放位置
network.host: 0.0.0.0 			    #可以访问集群的地址
http.port: 9200  	     		    #集群开放端口

# 节点发现，所有节点的 ip 地址及端口（端口默认为 9300）
discovery.seed_hosts: ["192.168.110.26","192.168.110.25","192.168.110.24"]    
#配置集群节点/单节点配置一个ip即可
cluster.initial_master_nodes: ["es1"，"es2","es3"]
# 哪些节点允许被选举为 master，与 node.name 保持一致
# 集群初次启动的时候该参数起作用，启动成功之后该参数可以删除
# 集群重启或者新增节点时不需要此参数

#允许跨域访问
http.cors.enabled: true 
http.cors.allow-origin: "*"
```

​		

## 1.4启动elasticsearch

```shell
systemctl start elasticsearch && systemctl enable elasticsearch    #启动elasticsearch并开机自启
```

