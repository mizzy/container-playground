#!/bin/sh

if [ ! -x /usr/local/bin/firecracker ]; then
    git clone https://github.com/firecracker-microvm/firecracker
    cd firecracker
    tools/devtool -y build
    mv build/debug/firecracker /usr/local/bin
fi
