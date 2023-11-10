# elasticSearch：使用Kibana对数据进行增删改查（CRUD）

## 1.新增
### 1.1.1新增ES索引库
#### PUT/索引名
```shell
PUT /student
```
### 1.1.2新增一条数据 并指定id
#### PUT 索引名/type/id
```shell
PUT /student/_doc/1 #也可以不指定id，id会随机生成
{
"address":"北京",
"name":"百度"
}
```
### 1.1.3 批量新增数据
#### PUT索引名/别名/_bulk
```shell
PUT /student/_doc/_bulk
{"index":{"_id":1}}
{"name":"百度","address":"北京"}
{"index":{"_id":2}}
{"name":"优酷","address":"上海"}
{"index":{"_id":3}}
{"name":"美团","address":"武汉"}
```
## 2.删除
### 2.1删除索引库
#### DELETE/索引名
```shell
DELETE student
```
### 2.2指定id删除索引
#### DELETE index名/type名/id
```shell
DELETE shici/_doc/89jxRosBL_MAGt6M7ZoM
```
### 2.3 批量指定数据删除
#### POST 索引名/type/_delete_by_query
```shell
POST /student/_doc/_delete_by_query
{
"query":{
"term":{
"_id":"1"    #大括号内是条件，满足该条件得项目全部删除
}
}
}
```
### 2.4 删除所有数据，不删表结构。效果同Mysql中的truncate
#### post /索引名/type/_delete_by_query
```shell
POST /student/_doc/_delete_by_query
{
"query":{
"match_all":{
}
}
}
```
**两种删除方式的区别：**

post在请求发送后刷新查询设计的所有分片
delete仅刷新接收删除请求的分片
## 3.修改
### 3.1全量字段修改指定字段值
#### 同新增逻辑 ，把全量字段复制过来，然后将需要修改的字段值更改
```shell
POST student/_doc/1
{
"address" : "北京",
"name" : "baidu"
}
```
### 3.2修改指定直段值
#### POTY 索引名/type名/id/_update
```shell
POST student/_doc/1/_update
{
"doc":{
"name":"腾讯"
}
}
```
## 4.查询
### 4.1查询数据结构
#### 查询索引名下所有type中mapping类型的数据结构
```shell
GET /student1
```
### 4.2查询指定type的数据结构

### 4.3查询项目数据
#### 查询索引名下所有type的所有数据
```shell
GET /student/_search
```
### 4.4查询指定type下符合条件的数据
```shell
GET /student/_doc/_search
```
## 修改分片和副本数量
```shell
POST /_reindex
{
  "source": {
    "index": "old_index"   #旧索引的数据拷贝到新索引中
  }
  , "dest": {
    "index": "new_index"   #创建的新索引分配号分片数和副本数
  }
}
```