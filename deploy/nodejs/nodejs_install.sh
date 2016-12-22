#!/bin/sh
sudo apt-get install g++ curl libssl-dev apache2-utils git-core -y
mkdir -p  /tmp/nodejs
cd /tmp/nodejs
wget http://nodejs.org/dist/v0.10.4/node-v0.10.4.tar.gz
tar xzf node-v0.10.4.tar.gz
cd node-v0.10.4
./configure --prefix=/usr/local
make && make install 
echo 'export PATH=$PATH:/usr/local/node/bin' >> ~/.bash_profile 

source ~/.bash_profile
curl http://npmjs.org/install.sh | sudo sh
npm install juggernaut
