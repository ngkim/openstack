#!/bin/bash

apt-get update

apt-get -y install sysstat numactl htop iftop

mkdir -p $HOME/.config/htop
cp conf/htoprc $HOME/.config/htop
