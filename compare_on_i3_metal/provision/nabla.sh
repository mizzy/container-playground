#!/bin/bash

if [ ! -x /usr/local/bin/runnc ]; then
    GOPATH=/root/go
    if [ ! -d $GOPATH ]; then
        mkdir -p $GOPATH/src/github.com/opencontainers
    fi

    go get github.com/nabla-containers/runnc

    cd ~/go/src/github.com/nabla-containers
    rm -rf runnc
    git clone https://github.com/nabla-containers/runnc.git
    cd runnc
    git checkout b78fe29
    git submodule update --init
    make build
    make install
    apt-get install genisoimage

    cat <<EOF >> /etc/containerd/config.toml
[plugins]
  [plugins.linux]
    shim = "containerd-shim"
    runtime = "runnc"
EOF

fi


