#!/bin/sh

apt-get update

apt-get -y install gcc make pkg-config libseccomp-dev

# Insall Go
if [ ! -f go1.11.5.linux-amd64.tar.gz ]; then
    curl -s -O https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.11.5.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
fi

# Install Docker
if [ ! -x /usr/bin/docker ]; then
    apt-get remove docker docker-engine docker.io containerd runc
    apt-get -y install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | apt-key add -

    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

    apt-get update

    apt-get -y install docker-ce docker-ce-cli containerd.io
fi

# Install Nabla Containers
if [ ! -x /usr/local/bin/runnc ]; then
    GOPATH=/root/go
    if [ ! -d $GOPATH ]; then
        mkdir -p $GOPATH/src/github.com/opencontainers
    fi

    mkdir -p ~/go
    go get github.com/nabla-containers/runnc

    cd ~/go/src/github.com/nabla-containers/runnc
    make container-build
    make container-install
    apt-get install genisoimage
fi

# Install gVisor
if [ ! -x /usr/local/bin/runsc ]; then
    wget -q https://storage.googleapis.com/gvisor/releases/nightly/latest/runsc
    wget -q https://storage.googleapis.com/gvisor/releases/nightly/latest/runsc.sha512
    sha512sum -c runsc.sha512
    chmod a+x runsc
    mv runsc /usr/local/bin
fi

# Install Firecracker
if [ ! -x /usr/local/bin/firecracker ]; then
    git clone https://github.com/firecracker-microvm/firecracker
    cd firecracker
    tools/devtool -y build
    mv build/debug/firecracker /usr/local/bin
fi

# Install Kata Containers
if [ ! -x /usr/bin/kata-runtime ]; then
    ARCH=$(arch)
    sh -c \
       "echo 'deb http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/stable-1.5/xUbuntu_$(lsb_release -rs)/ /' \
  > /etc/apt/sources.list.d/kata-containers.list"
    curl -sL \
         http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/master/xUbuntu_$(lsb_release -rs)/Release.key \
        | apt-key add -
    apt-get update
    apt-get -y install kata-runtime kata-proxy kata-shim
fi

