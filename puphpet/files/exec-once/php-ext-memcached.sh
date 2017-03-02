#!/bin/bash

# libmemcached
cp /vagrant/install/php/libmemcached-1.0.18.tar.gz ./
tar xzf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18
./configure
make
make install

# ext-memcached

cd ..
cp /vagrant/install/php/memcached-2.2.0.tgz ./
tar xzf memcached-2.2.0.tgz
cd memcached-2.2.0
phpize
php-config
./configure --disable-memcached-sasl --enable-memcached-igbinary
make
make install
service php-fpm restart
