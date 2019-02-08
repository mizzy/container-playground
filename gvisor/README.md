# gVisor Playground

## Pointers

- [google/gvisor: Container Runtime Sandbox](https://github.com/google/gvisor)
- [gvisor/quick_start.md at master · google/gvisor](https://github.com/google/gvisor/blob/master/docs/user_guide/quick_start.md)
- [minikube/README.md at master · kubernetes/minikube](https://github.com/kubernetes/minikube/blob/master/deploy/addons/gvisor/README.md)
- [google/gvisor-containerd-shim: containerd shim for gVisor](https://github.com/google/gvisor-containerd-shim)

## Using runsc

### Run an OCI compatible container

```sh
mkdir bundle
cd bundle
mkdir rootfs
sudo docker export $(sudo docker create busybox) | tar -xf - -C rootfs
runsc spec
sudo runsc run hello
```

This does not show a command prompt, but you can execute commands.


```
$ ps -ef|grep runsc
root     15420 15365  0 09:15 pts/0    00:00:00 sudo runsc run hello
root     15421 15420  0 09:15 pts/0    00:00:00 runsc run hello
root     15426 15421  0 09:15 pts/0    00:00:00 runsc-gofer --root=/var/run/runsc --debug=false --log= --log-format=text --debug-log= --debug-log-format=text --file-access=exclusive --overlay=false --network=sandbox --log-packets=false --platform=ptrace --strace=false --strace-syscalls= --strace-log-size=1024 --watchdog-action=LogWarning --panic-signal=-1 gofer --bundle /home/vagrant/bundle --spec-fd=3 --io-fds=4 --apply-caps=false --setup-root=false
nobody   15427 15421  2 09:15 ?        00:00:01 runsc-sandbox --root=/var/run/runsc --debug=false --log= --log-format=text --debug-log= --debug-log-format=text --file-access=exclusive --overlay=false --network=sandbox --log-packets=false --platform=ptrace --strace=false --strace-syscalls= --strace-log-size=1024 --watchdog-action=LogWarning --panic-signal=-1 boot --bundle=/home/vagrant/bundle --controller-fd=3 --spec-fd=4 --start-sync-fd=5 --io-fds=6 --stdio-fds=7 --stdio-fds=8 --stdio-fds=9 hello
```

### Run with Docker

/etc/docker/daemon.json

```json
{
    "runtimes": {
        "runsc": {
            "path": "/usr/local/bin/runsc"
        }
    }
}
```

```sh
sudo systemctl restart docker
```

```sh
sudo docker run -ti --runtime=runsc busybox /bin/sh
```

```sh
$ ps -ef|grep runsc
root      5409  4486  0 12:30 pts/0    00:00:00 sudo docker run -ti --runtime=runsc busybox /bin/sh
root      5410  5409  0 12:30 pts/0    00:00:00 docker run -ti --runtime=runsc busybox /bin/sh
root      5432  3102  0 12:30 ?        00:00:00 containerd-shim -namespace moby -workdir /var/lib/containerd/io.containerd.runtime.v1.linux/moby/01adddacabeff4db8e095bc90e5ec6b3593368f304604358976fa2e741be598c -address /run/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runsc
root      5453  5432  0 12:30 ?        00:00:00 runsc-gofer --root=/var/run/docker/runtime-runsc/moby --debug=false --log=/run/containerd/io.containerd.runtime.v1.linux/moby/01adddacabeff4db8e095bc90e5ec6b3593368f304604358976fa2e741be598c/log.json --log-format=json --debug-log= --debug-log-format=text --file-access=exclusive --overlay=false --network=sandbox --log-packets=false --platform=ptrace --strace=false --strace-syscalls= --strace-log-size=1024 --watchdog-action=LogWarning --panic-signal=-1 --log-fd=3 gofer --bundle /run/containerd/io.containerd.runtime.v1.linux/moby/01adddacabeff4db8e095bc90e5ec6b3593368f304604358976fa2e741be598c --spec-fd=4 --io-fds=5 --io-fds=6 --io-fds=7 --io-fds=8 --apply-caps=false --setup-root=false
nobody    5458  5432  1 12:30 pts/2    00:00:00 runsc-sandbox --root=/var/run/docker/runtime-runsc/moby --debug=false --log=/run/containerd/io.containerd.runtime.v1.linux/moby/01adddacabeff4db8e095bc90e5ec6b3593368f304604358976fa2e741be598c/log.json --log-format=json --debug-log= --debug-log-format=text --file-access=exclusive --overlay=false --network=sandbox --log-packets=false --platform=ptrace --strace=false --strace-syscalls= --strace-log-size=1024 --watchdog-action=LogWarning --panic-signal=-1 --log-fd=3 boot --bundle=/run/containerd/io.containerd.runtime.v1.linux/moby/01adddacabeff4db8e095bc90e5ec6b3593368f304604358976fa2e741be598c --controller-fd=4 --spec-fd=5 --start-sync-fd=6 --io-fds=7 --io-fds=8 --io-fds=9 --io-fds=10 --console=true --stdio-fds=11 --stdio-fds=12 --stdio-fds=13 --cpu-num 2 01adddacabeff4db8e095bc90e5ec6b3593368f304604358976fa2e741be598c
```
