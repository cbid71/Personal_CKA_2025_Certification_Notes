1. Get etcdctl utility if it's not already present.
go get github.com/coreos/etcd/etcdctl

export ETCDCTL_API=3

YES, the export ETCDCTL_API=3 is important

2. Backup
ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 snapshot save \
     --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --cert=/etc/kubernetes/pki/etcd/server.crt \
     --key=/etc/kubernetes/pki/etcd/server.key \
     /opt/snapshot-pre-boot.db


You will find thoses 3 variables in `cat /etc/kubernetes/manifests/etcd.yaml`
- for cacert ===> --trusted-ca-file
- for cert =====> --cert-file
- for key ======> --key-file


          -----------------------------

          Disaster Happens

          -----------------------------
3. Restore ETCD Snapshot to a new folder
ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --name=master \
     --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
     --data-dir /var/lib/etcd-from-backup \
     --initial-cluster=master=https://127.0.0.1:2380 \
     --initial-cluster-token etcd-cluster-1 \
     --initial-advertise-peer-urls=https://127.0.0.1:2380 \
     snapshot restore /opt/snapshot-pre-boot.db

We can have even more simple

```
etcdctl snapshot restore --data-dir /var/lib/etcd-from-backup /opt/snapshot-pre-boot.db
```


 4. Modify /etc/kubernetes/manifests/etcd.yaml
 Update --data-dir to use new target location
 --data-dir=/var/lib/etcd-from-backup

 Update new initial-cluster-token to specify new cluster
 --initial-cluster-token=etcd-cluster-1

 Update volumes and volume mounts to point to new path
      volumeMounts:
          - mountPath: /var/lib/etcd-from-backup
            name: etcd-data
          - mountPath: /etc/kubernetes/pki/etcd
            name: etcd-certs
   hostNetwork: true
   priorityClassName: system-cluster-critical
   volumes:
   - hostPath:
       path: /var/lib/etcd-from-backup
       type: DirectoryOrCreate
     name: etcd-data
   - hostPath:
       path: /etc/kubernetes/pki/etcd
       type: DirectoryOrCreate
     name: etcd-certs


NOTE : you do not have to reboot, it will be taken after a few minutes

Remember to check etcd-controlplane to see if there is a problem : 

```
kubectl describe pod etcd-controlplane -n kube-system
```


