#!/bin/sh

./provision/packages.sh
./provision/go.sh
./provision/docker.sh
./provision/nabla.sh
./provision/gvisor.sh
./provision/firecracker.sh
./provision/kata.sh

