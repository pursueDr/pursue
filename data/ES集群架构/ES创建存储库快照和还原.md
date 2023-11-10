# ES创建存储库快照和还原

**快照是正在运行的 Elasticsearch 集群的备份。您可以使用快照执行以下操作：**
### 注册存储库
**要注册共享文件系统存储库，请先将文件系统挂载到 所有主节点和数据节点上的相同位置。然后添加文件系统的 中设置的路径或父目录 每个主节点和数据节点。对于正在运行的群集，这需要滚动重新启动每个节点。**

```shell
#进入/etc/elasticsearch/elasticsearch.yml 每个节点都需要添加挂载路径，修改完成需要重启每
个节点
path:
repo:
- /mnt/backup
```
### 在kibana上进行创建存储库
```shell
PUT _snapshot/mnt
{
"type": "fs"
, "settings": {
"location": "/mnt/backup"      #存储路径
    }
}
```
### 创建索引快照

```shell
#针对具体的index创建快照备份，其中snapshot_name 是快照的名字。
PUT _snapshot/backup/snapshot_name #backup是存储库名字
{
"indices": "wg"
}
```

## NFS持久化索引快照和恢复

首先所有节点先下载NFS并进行挂载
```shell
yum -y install nfs-utils.service    #下载NFS

vim /etc/exports     #进行nfs配置

/mnt/backup *(rw,sync,no_root_squash)   ## 要挂在的路径、*代表所有地址都可访问、 （读写权限，同步，压缩root用户）

exports -a    
#重启nfs
systemctl restart nfs
```
尝试挂载
```shell
showmount -e < IP地址 >
```
进入vim /etc/elasticsearch/elasticsearch.yml文件下设置存储库路径
```shell
path:
  repo:
    - /mnt/backup    #存储库路径为nfs共享目录路径
```
### kibana上创建存储库
```shell
PUT _snapshot/my_backup           #my_backup 为存储库名字
{
  "type": "fs"
  , "settings": {
    "location": "/mnt/backup",    #存储库路径
    "compress": true
  }
}
```
![Alt text](%E5%88%9B%E5%BB%BA%E5%AD%98%E5%82%A8%E5%BA%93-1.jpg)

### 创建索引快照
```shell
PUT _snapshot/my_backup/zq            #zq为索引快照名字
{
  "indices": "wg"        #要快照的索引
}
```

### 恢复索引快照
```shell
POST _snapshot/my_backup/zq/_restore
{
  "indices": "wg"
}
```