update kubeadm

- modifier /etc/apt/sources.list.d/kubernetes
nano /etc/apt/sources.list.d/kubernetes.list 
---> 1.32

PUIS

apt-get update

apt-cache madison kubeadm		# pour connaitre les versions de kubeadm disponibles

apt-get upgrade kubeadm=1.32.0-blablabla


kubeadm upgrade plan
kubeadm apply plan v1.32.3
systemctl restart kubelet

kubectl cordon node01
kubectl drain node01 --ignore-daemonset

ssh node01

- modifier /etc/apt/sources.list.d/kubernetes
nano /etc/apt/sources.list.d/kubernetes.list
---> apt-get update

apt-get upgrade kube*

systemctl restart kubelet

exit

kubectl uncordon node01

# Pour le rapport json

kubectl -n admin2406 get deployment -o custom-columns=DEPLOYMENT:.metadata.name,CONTAINER_IMAGE:.spec.template.spec.containers[].image,READY_REPLICAS:.status.readyReplicas,NAMESPACE:.metadata.namespace --sort-by=.metadata.name > /opt/admin2406_data

# About the pod on node01
		https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity


# A propos de la mise à jour de pod

kubectl set image deployment/nginx-deployment nginx=nginx:1.17 --record
kubectl annotate deployment nginx-deployment kubernetes.io/change-cause="Updated nginx image to 1.17"


J'ai dû recréer le PVC pour matcher les infos du volumename existant

- accessmode
- storage
- storageclass
- volumename

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  name: alpha-claim
  namespace: alpha
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: slow
  volumeName: alpha-pv
  volumeMode: Filesystem
```



Monter un secret sur un pod
	https://kubernetes.io/fr/docs/concepts/configuration/secret/

En fait le pod référençait un mauvais non de pvc


Ensuite etcd


etcdctl --endpoints=https://192.168.183.247:2379 --key-file=/etc/kubernetes/pki/etcd/server.key --cert-file=/etc/kubernetes/pki/etcd/server.crt --ca-file=/etc/kubernetes/pki/etcd/ca.crt backup --data-dir=/var/lib/etcd --backup-dir=/opt/etcd-backup.db


Deployer un pod

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-1401        
spec:
  volumes:
    - name: secret-volume
      secret:
        secretName: dotfile-secret
  containers:
    - name: dotfile-test-container
      image: registry.k8s.io/busybox
      command:
        - ls
        - "-l"
        - "/etc/secret-volume"
      volumeMounts:
        - name: secret-volume
          readOnly: true
          mountPath: "/etc/secret-volume"
```
