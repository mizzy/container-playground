#!/bin/bash

# runc
echo "##### runc"
time sudo runc run mycontainer
echo

# gVisor
echo "##### gVisor"
time sudo runsc -log /dev/null run mycontainer
echo

# Kata Containers
echo "##### Kata Containers"
time sudo kata-runtime run mycontainer

time sudo runnc create abcdefg123456 && sudo runnc start abcdefg123456

