# Nabla containers

## Pointers

- [Nabla containers: a new approach to container isolation · Nabla Containers](https://nabla-containers.github.io/)
- [Nabla Containers](https://github.com/nabla-containers)
- [nabla-containers/nabla-measurements: Measurements and comparisons of nabla containers](https://github.com/nabla-containers/nabla-measurements)
- [Running a Nabla Container · Nabla Containers](https://nabla-containers.github.io/2018/06/28/nabla-setup/)

## Running a Nabla Container

### Build and install runnc

```sh
mkdir -p ~/go
go get github.com/nabla-containers/runnc
```

I saw this error, but ignored.

```
package github.com/opencontainers/runc/libcontainer/label: cannot find package "github.com/opencontainers/runc/libcontainer/label" in any of:
        /usr/local/go/src/github.com/opencontainers/runc/libcontainer/label (from $GOROOT)
        /home/vagrant/go/src/github.com/opencontainers/runc/libcontainer/label (from $GOPATH)
```

```sh
cd go/src/github.com/nabla-containers/runnc
make container-build
make container-install
```


### Installing the runtime for docker

```sh
sudo apt install -y genisoimage
```


/etc/docker/daemon.json


```json
{
    "runtimes": {
        "runnc": {
                "path": "/usr/local/bin/runnc"
        }
    }
}
```

```sh
sudo systemctl restart docker
```


### Creating our first nabla container

```sh
sudo docker run --rm -p 8080:8080 --runtime=runnc nablact/node-express-nabla
```


```
curl localhost:8080
```


```sh
ps -ef|grep runnc
root     16689  9703  0 04:19 pts/0    00:00:00 sudo docker run --rm -p 8080:8080 --runtime=runnc nablact/node-express-nabla
root     16690 16689  0 04:19 pts/0    00:00:00 docker run --rm -p 8080:8080 --runtime=runnc nablact/node-express-nabla
root     16759  8282  0 04:19 ?        00:00:00 containerd-shim -namespace moby -workdir /var/lib/containerd/io.containerd.runtime.v1.linux/moby/f890dd474526621d7232f0f07d803ed7dd2dc82dfaf2411bf45a956352b2dc6a -address /run/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runnc
root     16779 16759  1 04:19 ?        00:00:00 /opt/runnc/bin/nabla-run --mem=512 --net-mac=02:42:ac:11:00:02 --net=tapf890dd474526 --disk=/var/run/docker/runtime-runnc/moby/f890dd474526621d7232f0f07d803ed7dd2dc82dfaf2411bf45a956352b2dc6a/rootfs.iso /var/lib/docker/overlay2/dfc849b4eac55398ce9280f3edfae554db54d54a019cacd724bfb95fe687d211/merged/node.nabla {"env":"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","env":"HOSTNAME=f890dd474526","cmdline":"/var/lib/docker/overlay2/dfc849b4eac55398ce9280f3edfae554db54d54a019cacd724bfb95fe687d211/merged/node.nabla /home/node/app/app.js","net":{"if":"ukvmif0","cloner":"True","type":"inet","method":"static","addr":"172.17.0.2","mask":"16","gw":"172.17.0.1"},"blk":{"source":"etfs","path":"/dev/ld0a","fstype":"blk","mountpoint":"/"},"cwd":"/"}
```
