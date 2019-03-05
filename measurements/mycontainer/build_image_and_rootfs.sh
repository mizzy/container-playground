#!/bin/sh

set -eux

make all

sudo docker build . -t image

cid=`sudo docker create image /hello`
mkdir -p rootfs
sudo docker export $cid | tar -C rootfs -xvf -

