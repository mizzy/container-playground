# runc

## Overview

- [opencontainers/runc: CLI tool for spawning and running containers according to the OCI specification](https://github.com/opencontainers/runc)


## Using runc

### Creating an OCI Bundle

```sh
mkdir mycontainer
cd mycontainer
mkdir rootfs
cid=`sudo docker create busybox`
sudo docker export $cid | tar -C rootfs -xvf -
runc spec
```

### Running Containers

Under `mycontainer` directory:

```sh
sudo runc run mycontainerid
/ #
/ # uname -n
runc
/ # id
uid=0(root) gid=0(root)
```


On another terminal:

```
sudo runc list
ID              PID         STATUS      BUNDLE                      CREATED                         OWNER
mycontainerid   18750       running     /home/vagrant/mycontainer   2019-02-07T01:06:08.41163043Z   root

sudo ps f
  PID TTY      STAT   TIME COMMAND
18773 pts/1    S+     0:00 sudo ps f
18774 pts/1    R+     0:00  \_ ps f
18729 pts/0    S+     0:00 sudo runc run mycontainerid
18730 pts/0    Sl+    0:00  \_ runc run mycontainerid
18750 pts/0    Ss+    0:00      \_ sh
```
### Lifecycle Operations

Modify `config.json`.

```diff
--- config.json.org     2019-02-07 01:12:49.023777804 +0000
+++ config.json 2019-02-07 01:13:18.715777804 +0000
@@ -1,13 +1,13 @@
 {
        "ociVersion": "1.0.1-dev",
        "process": {
-               "terminal": true,
+               "terminal": false,
                "user": {
                        "uid": 0,
                        "gid": 0
                },
                "args": [
-                       "sh"
+                       "sleep", " 5"
                ],
                "env": [
                        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
@@ -175,4 +175,4 @@
                        "/proc/sysrq-trigger"
                ]
        }
-}
\ No newline at end of file
+}
```

```sh
sudo runc create mycontainerid
sudo runc list
ID              PID         STATUS      BUNDLE                      CREATED                          OWNER
mycontainerid   18972       created     /home/vagrant/mycontainer   2019-02-07T01:56:52.337417123Z   root
sudo runc start mycontainerid
sudo runc list
ID              PID         STATUS      BUNDLE                      CREATED                          OWNER
mycontainerid   18972       running     /home/vagrant/mycontainer   2019-02-07T01:56:52.337417123Z   root
# After 5 seconds
sudo runc list
ID              PID         STATUS      BUNDLE                      CREATED                          OWNER
mycontainerid   0           stopped     /home/vagrant/mycontainer   2019-02-07T01:56:52.337417123Z   root
sudo runc delete mycontainerid
```

### Rootless containers


```sh
mkdir mycontainer
cd mycontainer
mkdir rootfs
cid=`sudo docker create busybox`
sudo docker export $cid | tar -C rootfs -xvf -
runc spec --rootless
runc --root /tmp/runc run mycontainerid
```
