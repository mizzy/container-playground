#!/bin/bash

set -eux

make all

sudo docker build . -t image

cid=`sudo docker create image /hello`
mkdir -p rootfs
sudo docker export $cid | tar -C rootfs -xvf -

pushd ..

git clone https://github.com/nabla-containers/solo5.git
pushd solo5
./configure.sh
make
sudo cp kernel/ukvm/solo5.o /usr/lib/libsolo5_seccomp.a

popd

git clone https://github.com/nabla-containers/rumprun.git
pushd rumprun
git submodule update --init
sudo apt install zlib1g-dev 
CC=cc ./build-rr.sh solo5 -- -F CFLAGS="-Wimplicit-fallthrough=0 -Wno-maybe-uninitialized"
sudo cp rumprun-solo5/bin/x86_64-rumprun-netbsd-gcc /usr/local/bin
sudo cp obj-amd64-solo5-solo5/dest.stage/bin/rumprun-bake /usr/local/bin

popd
popd

x86_64-rumprun-netbsd-gcc -o hello.out hello.c
rumprun-bake solo5_spt hello.nabla hello.out

x86_64-rumprun-netbsd-gcc -o loop.out loop.c
rumprun-bake solo5_spt loop.nabla loop.out

sudo docker build . -t image-for-nabla -f Dockerfile_for_nabla
