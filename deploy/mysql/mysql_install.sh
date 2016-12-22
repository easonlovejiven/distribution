#!/usr/bin/env bash
MY_CNF=$PWD/my.cnf
##安装依赖
apt-get install build-essential -y
sudo apt-get install libaio-dev -y
sudo apt-get install -y libaio1
##下载安装
sudo apt-get remove -y mysql-common mysql-server mysql-client
sudo rm -rf /etc/mysql/
cd /usr/local/src/
sudo wget "http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.11-linux-glibc2.5-x86_64.tar.gz"
sudo tar xzf mysql-5.6.11-linux-glibc2.5-x86_64.tar.gz
sudo mv  mysql-5.6.11-linux-glibc2.5-x86_64 /usr/local/ -rf
cd /usr/local/
sudo ln -s mysql-5.6.11-linux-glibc2.5-x86_64 mysql
#环境变量
echo 'export PATH=$PATH:/usr/local/mysql/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile 
#初始数据库
sudo mkdir /var/lib/mysql
sudo mkdir /var/run/mysqld
/usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir=/var/lib/mysql --basedir=/usr/local/mysql
#权限
addgroup mysql
useradd mysql -g mysql
chown -R root:mysql /usr/local/mysql
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql
#mysql配置
cp $MY_CNF /etc/mysql/my.cnf
#更新
#mysqld_safe --user=mysql &
#mysql_upgrade
#启动
cd /usr/local/mysql/support-files/
cp mysql.server /etc/init.d/mysql
sudo chmod +x /etc/init.d/mysql
update-rc.d mysql defaults
sudo /etc/init.d/mysql start
./bin/mysqladmin -u root password '123456'
sudo /etc/init.d/mysql restart



