#! /bin/sh
sudo apt-get install libmysqlclient15-dev
DIR=$PWD

wget http://sphinxsearch.com/files/sphinx-2.0.7-release.tar.gz -O sphinx.tar.gz
tar xzvf sphinx.tar.gz
cd sphinx-2.0.7-release
./configure  --prefix=/usr/local/sphinx --with-mysql
make
sudo make install
adduser --system --group sphinx
sudo chown -R sphinx:sphinx /usr/local/sphinx/
cd ..
#启动脚本
cp $DIR/sphinx_init.sh /etc/init.d/searchd
chown root:root /etc/init.d/searchd
chmod 755 /etc/init.d/searchd
cd /usr/local/sphinx/etc/
cp sphinx.conf.dist sphinx.conf

#sudo update-rc.d searchd defaults
