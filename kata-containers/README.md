# Kata Containers

## Pointers

- [Kata Containers - The speed of containers, the security of VMs](https://katacontainers.io/)
- [Kata Containers](https://github.com/kata-containers)
- [documentation/install at master · kata-containers/documentation](https://github.com/kata-containers/documentation/tree/master/install)
- [documentation/ubuntu-installation-guide.md at master · kata-containers/documentation](https://github.com/kata-containers/documentation/blob/master/install/ubuntu-installation-guide.md)

## Getting Started

### Installing Kata Containers on Ubuntu

```sh
ARCH=$(arch)
sudo sh -c \
  "echo 'deb http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/master/xUbuntu_$(lsb_release -rs)/ /' \
  > /etc/apt/sources.list.d/kata-containers.list"
curl -sL \
  http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/master/xUbuntu_$(lsb_release -rs)/Release.key \
  | sudo apt-key add -
sudo -E apt-get update
sudo -E apt-get -y install kata-runtime kata-proxy kata-shim
```

### Running with Docker

```sh
sudo mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/kata-containers.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -D --add-runtime kata-runtime=/usr/bin/kata-runtime --default-runtime=kata-runtime
EOF
```

Add the following definitions to `/etc/docker/daemon.json`:

```json
{
  "default-runtime": "kata-runtime",
  "runtimes": {
    "kata-runtime": {
      "path": "/usr/bin/kata-runtime"
    }
  }
}
```

Restart the Docker systemd service with the following commands:

```sh
sudo systemctl daemon-reload
sudo systemctl restart docker
```

Run the container.


```sh
sudo docker run -ti  --runtime=kata-runtime busybox /bin/sh
```

```sh
$ ps -ef|grep kata
root      7369  5297  0 01:52 pts/0    00:00:00 sudo docker run -ti --runtime=kata-runtime busybox /bin/sh
root      7370  7369  0 01:52 pts/0    00:00:00 docker run -ti --runtime=kata-runtime busybox /bin/sh
root      7398  3438  0 01:52 ?        00:00:00 containerd-shim -namespace moby -workdir /var/lib/containerd/io.containerd.runtime.v1.linux/moby/1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a -address /run/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-kata-runtime
root      7439  7398  6 01:52 ?        00:00:01 /usr/bin/qemu-lite-system-x86_64 -name sandbox-1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a -uuid cb31ff50-8873-44b2-88c5-aa48914f6284 -machine pc,accel=kvm,kernel_irqchip,nvdimm -cpu host,pmu=off -qmp unix:/run/vc/vm/1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a/qmp.sock,server,nowait -m 2048M,slots=10,maxmem=3017M -device pci-bridge,bus=pci.0,id=pci-bridge-0,chassis_nr=1,shpc=on,addr=2,romfile= -device virtio-serial-pci,disable-modern=true,id=serial0,romfile= -device virtconsole,chardev=charconsole0,id=console0 -chardev socket,id=charconsole0,path=/run/vc/vm/1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a/console.sock,server,nowait -device nvdimm,id=nv0,memdev=mem0 -object memory-backend-file,id=mem0,mem-path=/usr/share/kata-containers/kata-containers-image_clearlinux_1.5.0_agent_a581aebf473.img,size=536870912 -device virtio-scsi-pci,id=scsi0,disable-modern=true,romfile= -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng,rng=rng0,romfile= -device virtserialport,chardev=charch0,id=channel0,name=agent.channel.0 -chardev socket,id=charch0,path=/run/vc/vm/1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a/kata.sock,server,nowait -device virtio-9p-pci,disable-modern=true,fsdev=extra-9p-kataShared,mount_tag=kataShared,romfile= -fsdev local,id=extra-9p-kataShared,path=/run/kata-containers/shared/sandboxes/1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a,security_model=none -netdev tap,id=network-0,vhost=on,vhostfds=3,fds=4 -device driver=virtio-net-pci,netdev=network-0,mac=02:42:ac:11:00:02,disable-modern=true,mq=on,vectors=4,romfile= -global kvm-pit.lost_tick_policy=discard -vga none -no-user-config -nodefaults -nographic -daemonize -kernel /usr/share/kata-containers/vmlinuz-4.14.67.22-18.container -append tsc=reliable no_timer_check rcupdate.rcu_expedited=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1 noreplace-smp reboot=k console=hvc0 console=hvc1 iommu=off cryptomgr.notests net.ifnames=0 pci=lastbus=0 root=/dev/pmem0p1 rootflags=dax,data=ordered,errors=remount-ro rw rootfstype=ext4 quiet systemd.show_status=false panic=1 nr_cpus=2 init=/usr/lib/systemd/systemd systemd.unit=kata-containers.target systemd.mask=systemd-networkd.service systemd.mask=systemd-networkd.socket -smp 1,cores=1,threads=1,sockets=1,maxcpus=2
root      7445  7398  0 01:52 ?        00:00:00 /usr/libexec/kata-containers/kata-proxy -listen-socket unix:///run/vc/sbs/1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a/proxy.sock -mux-socket /run/vc/vm/1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a/kata.sock -sandbox 1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a
root      7456  7398  0 01:52 pts/2    00:00:00 /usr/libexec/kata-containers/kata-shim -agent unix:///run/vc/sbs/1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a/proxy.sock -container 1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a -exec-id 1d0a0d693fb41bdd57f2686971c9c78115f16b97680f7245277a192814fba06a -terminal
```
