#!/usr/bin/env bash
#mysql-client libmysqlclient15-dev
sudo apt-get install make gcc g++ automake libtool libxml2-dev libexpat1-dev -y
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export LD_LIBRARY_PATH
cd /usr/local/src/
wget http://www.coreseek.cn/uploads/csft/4.0/coreseek-4.1-beta.tar.gz
tar xzvf coreseek-4.1-beta.tar.gz

cd coreseek-4.1-beta
##安装mmseg
cd mmseg-3.2.14
ACLOCAL_FLAGS="-I /usr/share/aclocal" ./bootstrap
./configure --prefix=/usr/local/mmseg3
 make && make install
cd ..
##安装coreseek
cd  csft-4.1
sh buildconf.sh
./configure --prefix=/usr/local/coreseek  --without-unixodbc --with-mmseg --with-mmseg-includes=/usr/local/mmseg3/include/mmseg/ --with-mmseg-libs=/usr/local/mmseg3/lib/ --with-mysql  --enable-threads=posix
make && make install
cd ..
##测试mmseg分词，coreseek搜索（需要预先设置好字符集为zh_CN.UTF-8，确保正确显示中文）
cd testpack
cat var/test/test.xml
#此时应该正确显示中文
/usr/local/mmseg3/bin/mmseg -d /usr/local/mmseg3/etc var/test/test.xml
/usr/local/coreseek/bin/indexer -c etc/csft.conf --all
/usr/local/coreseek/bin/search -c etc/csft.conf
