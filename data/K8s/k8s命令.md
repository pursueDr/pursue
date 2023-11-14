# k8s命令

### 容器内复制到本机的命令

```shell
kubectl cp -n default -c ecshop ecshop-dpn2-78dddbdb55-5qqnc:opt/docker/etc/nginx /opt/nginx/default-ecshop-config-claim-pvc-456e8136-9439-409c-bd6f-f575d2c0bce9
# kubectl cp -n <指定命名空间> -c <指定容器名> <pod名称>:文件路径 /复制到本机路径 
```

### 进入容器

```shell
#pod中单个容器
kubectl exec -it <pod名称> bash
#pod中多个容器
kubectl exec -it <pod名称> -c <容器名称> bash
```

### 查看pod详情

```shell
kubectl describe -n default pod ecshop-dpn2-56f6bdfff4-qm429
# -n 指定命名空间 <组件> <名称>
```