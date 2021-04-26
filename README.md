# k8s-vagrant-libvirt-portworx

This is a derivative project from:

https://github.com/dotnwat/k8s-vagrant-libvirt 

Includes a Portworx deployment on a 3 worker node cluster and 1 master node.

It creates 3 virtual disks per worker node. Uses 6GB of RAM per node, I would recommend to have at least 32GB of RAM on your host.

Portworx pods will take up to 10 minutes to become ready.

```
[~/src/k8s-vagrant-portworx]$ POD=$(kubectl get pods -o wide -n kube-system -l name=portworx | tail -1 | awk '{print $1}')
[~/src/k8s-vagrant-portworx]$ kubectl exec -it pod/${POD} -n kube-system -- /opt/pwx/bin/pxctl status
Status: PX is operational
License: Trial (expires in 31 days)
Node ID: 2f0273da-c5dc-4e02-95e4-9b23fc81bfee
        IP: 192.168.121.151 
        Local Storage Pool: 1 pool
        POOL    IO_PRIORITY     RAID_LEVEL      USABLE  USED    STATUS  ZONE    REGION
        0       HIGH            raid0           57 GiB  6.0 GiB Online  default default
        Local Storage Devices: 2 devices
        Device  Path            Media Type              Size            Last-Scan
        0:1     /dev/vdb2       STORAGE_MEDIUM_MAGNETIC 27 GiB          26 Apr 21 17:28 UTC
        0:2     /dev/vdc        STORAGE_MEDIUM_MAGNETIC 30 GiB          26 Apr 21 17:28 UTC
        total                   -                       57 GiB
        Cache Devices:
         * No cache devices
        Kvdb Device:
        Device Path     Size
        /dev/vdd        30 GiB
         * Internal kvdb on this node is using this dedicated kvdb device to store its data.
        Journal Device: 
        1       /dev/vdb1       STORAGE_MEDIUM_MAGNETIC
Cluster Summary
        Cluster ID: px-cluster-2b334603-86dd-4887-abba-90100a5e527b
        Cluster UUID: 2d2010a3-03c3-4428-8a54-dd098d2c804b
        Scheduler: kubernetes
        Nodes: 3 node(s) with storage (3 online)
        IP              ID                                      SchedulerNodeName       StorageNode     Used    Capacity        Status  StorageStatus   Version      Kernel                   OS
        192.168.121.99  fe225da9-67fa-4260-a8ac-16ffdb85985a    worker0                 Yes             6.0 GiB 57 GiB          Online  Up              2.6.3.0-4419aa4       3.10.0-1127.el7.x86_64  CentOS Linux 7 (Core)
        192.168.121.27  696d1d6a-ddf0-414f-85c1-99c69945d187    worker2                 Yes             6.0 GiB 57 GiB          Online  Up              2.6.3.0-4419aa4       3.10.0-1127.el7.x86_64  CentOS Linux 7 (Core)
        192.168.121.151 2f0273da-c5dc-4e02-95e4-9b23fc81bfee    worker1                 Yes             6.0 GiB 57 GiB          Online  Up (This node)  2.6.3.0-4419aa4       3.10.0-1127.el7.x86_64  CentOS Linux 7 (Core)
        Warnings: 
                 WARNING: Insufficient CPU resources. Detected: 2 cores, Minimum required: 4 cores
                 WARNING: Persistent journald logging is not enabled on this node.
Global Storage Pool
        Total Used      :  18 GiB
        Total Capacity  :  171 GiB
```

# k8s-vagrant-libvirt

A minimal setup for running multi-node kubernetes in vagrant virtual
machines using libvirt on linux.

Related projects:

* https://github.com/galexrt/k8s-vagrant-multi-node (virtualbox, many features)

Current supported configuration(s):

* guest: centos 7
* network: flannel

# usage

Create and provision the cluster

```bash
vagrant up --provider=libvirt
```

Set the kubectl configuration file

```bash
vagrant ssh master -c "sudo cat /etc/kubernetes/admin.conf" > ${HOME}/.kube/config
```

Test cluster access from your host

```
[~/src/k8s-vagrant-portworx]$ kubectl get nodes
NAME      STATUS   ROLES                  AGE   VERSION
master    Ready    control-plane,master   37m   v1.21.0
worker0   Ready    <none>                 36m   v1.21.0
worker1   Ready    <none>                 36m   v1.21.0
worker2   Ready    <none>                 36m   v1.21.0

```

# configuration

The following options may be set in the `Vagrantfile`

```ruby
# number of worker nodes
NUM_WORKERS = 3
# number of extra disks per worker
NUM_DISKS = 3
# size of each disk in gigabytes
DISK_GBS = 30
```

# loading docker images

Use the [vagrant-docker_load](https://rubygems.org/gems/vagrant-docker_load) plugin to upload Docker images into Vagrant machines

```bash
vagrant plugin install vagrant-docker_load
```

An example of loading a [rook@master](https://github.com/rook/rook) build

```bash
[~/src/k8s-vagrant-portworx]$ vagrant docker-load build-2568df12/ceph-amd64 rook/ceph:master
Loaded image: build-2568df12/ceph-amd64:latest
Loaded image: build-2568df12/ceph-amd64:latest
```

# troubleshooting

The following is a summary of the environments and applications that are known to work

```
[~/src/k8s-vagrant-portworx]$ lsb_release -d
Description: Fedora release 29 (Twenty Nine)

[~/src/k8s-vagrant-portworx]$ vagrant version
Installed Version: 2.1.2

[~/src/k8s-vagrant-portworx]$ vagrant plugin list
vagrant-libvirt (0.0.40, system)
```

Ceph distributed storage via Rook

```
[~/src/k8s-vagrant-portworx]$ kubectl -n rook-ceph-system logs rook-ceph-operator-b996864dd-l5czk | head -n 1
2019-03-21 16:09:18.168066 I | rookcmd: starting Rook v0.9.0-323.g2447520 with arguments '/usr/local/bin/rook ceph operator'

[~/src/k8s-vagrant-portworx]$ kubectl -n rook-ceph get pods
NAME                                  READY   STATUS      RESTARTS   AGE
rook-ceph-mgr-a-6b5cdfcb6f-hg7tr      1/1     Running     0          4m33s
rook-ceph-mon-a-6cb6cfdb95-grgsz      1/1     Running     0          4m56s
rook-ceph-mon-b-6477f5fc8c-m5mzg      1/1     Running     0          4m50s
rook-ceph-mon-c-6cdf75fc4c-pgq5h      1/1     Running     0          4m42s
rook-ceph-osd-0-8b5d9c477-5s989       1/1     Running     0          4m11s
rook-ceph-osd-prepare-worker0-x5qqn   0/2     Completed   0          4m17s
rook-ceph-tools-76c7d559b6-vcxhr      1/1     Running     0          3m48s
```
