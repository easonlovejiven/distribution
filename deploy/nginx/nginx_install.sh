#!/bin/sh
DIR=$PWD
#dependents
 apt-get install libpcre3-dev build-essential libssl-dev -y
#log
mkdir /var/log/nginx
#download &install
cd /usr/local/src
 wget 'http://nginx.org/download/nginx-1.3.4.tar.gz'
 tar xzvf nginx-1.3.4.tar.gz
cd /usr/local/src/nginx-1.3.4/
 ./configure --conf-path=/etc/nginx/nginx.conf \
--pid-path=/run/nginx.pid \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/http.log \
--user=ubuntu \
--group=ubuntu \
--with-http_ssl_module \
--with-http_stub_status_module \
--sbin-path=/usr/sbin/nginx  \
--with-http_gzip_static_module \
--with-ipv6
 make &&  make install
#config
 mkdir /etc/nginx/
 cp $DIR/nginx.conf /etc/nginx/
 mkdir /etc/nginx/sites-available
 mkdir /etc/nginx/sites-enabled
#project
 mkdir /var/www
 cp $DIR/default /etc/nginx/sites-available/
 ln -s  /etc/nginx/sites-available/default  /etc/nginx/sites-enabled/default
#permission
chown -R ubuntu:ubuntu /var/log/nginx
chown -R ubuntu:ubuntu /etc/nginx/sites-available/
chown -R ubuntu:ubuntu /etc/nginx/sites-enabled/
#init script
 cp $DIR/nginx_init.sh /etc/init.d/nginx
chmod +x /etc/init.d/nginx
 update-rc.d -f nginx defaults
 /etc/init.d/nginx restart
