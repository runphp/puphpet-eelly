#!/bin/bash

# libmemcached
cp /vagrant/install/php/libmemcached-1.0.18.tar.gz ./
tar xzf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18
./configure
make
make install

# igbinary dev
yum install php-pecl-igbinary-devel

# ext-memcached

cd ..
cp /vagrant/install/php/memcached-3.0.3.tgz ./
tar xzf memcached-3.0.3.tgz
cd memcached-3.0.3
phpize
php-config
./configure --disable-memcached-sasl --enable-memcached-igbinary
make
make install
tee /etc/php.d/memcached.ini <<< 'extension=memcached.so'
service php-fpm restart
