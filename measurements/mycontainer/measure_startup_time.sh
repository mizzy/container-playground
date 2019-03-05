#!/bin/bash

# runc
echo "##### runc"
time sudo runc run mycontainer
echo

# gVisor
echo "##### gVisor"
time sudo runsc -log /dev/null run mycontainer
