#!/bin/bash

if [ ! -x /usr/local/bin/containerd-shim-kata-v2 ]; then
    go get github.com/kata-containers/runtime
    cd go/src/github.com/kata-containers/runtime
    go get -u github.com/golang/dep/cmd/dep
    ~/go/bin/dep ensure
    make
    make install
    cd
fi

if [ ! -x /usr/bin/kata-runtime ]; then
    ARCH=$(arch)
    sh -c \
       "echo 'deb http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/stable-1.5/xUbuntu_16.04/ /' \
  > /etc/apt/sources.list.d/kata-containers.list"
    curl -sL \
         http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/master/xUbuntu_16.04/Release.key \
        | apt-key add -
    apt-get update
    apt install -t unstable librdb1
    apt-get -y install kata-runtime kata-proxy kata-shim
fi
