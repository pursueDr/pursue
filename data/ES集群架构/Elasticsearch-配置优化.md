#  Elasticsearch-配置优化

## 系统参数优化

### vim打开/etc/security/limits.conf文件

```shell
elasticsearch soft nofile 65535
elasticsearch hard nofile 65535
elasticsearch soft nproc 4096
elasticsearch hard nproc 4096
```

### vim打开/etc/sysctl.conf文件

```shell
vm.max_map_count = 655360
#修改完毕后重新加载
sysctl -p
```

### ES定义：存储和强大的搜索引擎