

# heml安装下载

```shell
wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar -zxvf helm-v3.6.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
# 安装完成后，在终端输入查看版本的命令，检查是否安装成功
helm version
```

## 添加仓库

```shell
 helm repo add stable https://charts.helm.sh/stable
 helm repo update
```

## 也可以通过编辑yaml文件的方式添加仓库

```shell
$ vim stable.yaml

apiVersion: v1
name: stable
url: https://charts.helm.sh/stable

#保存文件后，使用以下命令添加
helm repo add stable ./stable
helm repo update
```















