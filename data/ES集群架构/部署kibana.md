# 部署kibana

## yum下载kibana

```shell 
yum install kibana
```

## vim打开/etc//kibana/kibana.yml文件修改以下几行

```shell
server.port: 5601                                      #kibana开放端口
server.host: "0.0.0.0"                                 #可访问的ip
elasticsearch.hosts: ["http://192.168.110.26:9200"]    #部署在哪个主机
i18n.locale: "zh-CN"                                   #设置中文
```

## 启动kibana并设置开机自启

```shell
systemctl start kibana && systemctl enable kibana
```

