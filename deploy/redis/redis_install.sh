#! /bin/sh
DIR=$PWD
#下载安装
cd /usr/local/src
wget redis.googlecode.com/files/redis-2.6.12.tar.gz
tar xvzf redis-2.6.9.tar.gz
cd  redis-2.6.9
make
sudo make install
#
mkdir -p /usr/local/bin
cd src
cp -p redis-benchmark /usr/local/bin
cp -p redis-cli /usr/local/bin
cp -p redis-check-dump /usr/local/bin
cp -p redis-check-aof /usr/local/bin
#配置文件
sudo mkdir -p /var/lib/redis /etc/redis /var/log/redis
cp $DIR/redis.conf /etc/redis
#启动脚本
cp $DIR/redis-server /etc/init.d/
chmod +x /etc/init.d/redis-server
sudo update-rc.d redis-server defaults
#权限
sudo useradd --system --home-dir /var/lib/redis redis
sudo chown redis.redis /var/lib/redis
sudo chown redis.redis /var/log/redis

sudo update-rc.d redis-server defaults


sudo /etc/init.d/redis-server start
