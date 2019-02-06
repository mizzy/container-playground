#!/bin/sh

apt-get update
apt-get -y install gcc make pkg-config libseccomp-dev

if [ ! -f go1.11.5.linux-amd64.tar.gz ]; then
    curl -s -O https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.11.5.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
fi

GOPATH=/root/go
if [ ! -d $GOPATH ]; then
    mkdir -p $GOPATH/src/github.com/opencontainers
fi

if [ ! -f /usr/local/sbin/runc ]; then
    go get github.com/opencontainers/runc
    cd $GOPATH/src/github.com/opencontainers/runc
    make
    make install
fi
