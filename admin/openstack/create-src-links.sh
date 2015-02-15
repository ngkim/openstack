#!/bin/bash

if [ ! -d src ]; then
  echo "0. create directory 'src'"
  mkdir -p src
fi

echo "1. nova source link"
ln -s /usr/lib/python2.7/dist-packages/nova src/nova
echo "2. neutron source link"
ln -s /usr/lib/python2.7/dist-packages/neutron src/neutron
