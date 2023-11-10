#!/bin/sh
yum -y install expect

#生成ssh公钥

/usr/bin/expect <<-EOF
spawn ssh-keygen
expect "(/root/.ssh/id_rsa):"
send "\r"
expect "(empty for no passphrase):"
send "\r"
expect "Enter same passphrase again:"
send "\r"
expect eof
EOF
echo "公钥已生成"

#配置互信免密
for i in `cat ip.txt`
do 
/usr/bin/expect <<-EOF
spawn ssh-copy-id root@$i
expect "(yes/no)"
send "yes\r"
expect "password:"
send "123\r"
expect eof
EOF

if [ $? -eq 0 ];then
    echo "发送成功"
else
    echo "发送失败"
fi
done
