# because sometime we need help

kubectl config get cluster

docker run ubuntu sleep 3600
docker run --user=1000 ubuntu sleep 3600

kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx.yaml

kubectl expose pod redis-service --type=ClusterIP --port 6379 --dry-run=client -o yaml > service.yaml
kubectl expose deployment nginx --port 80

kubectl edit deployment nginx
kubectl scale deployment nginx --replicas=3
kubectl set image deployment nginx nginx=nginx=1.18
kubectl apply -f nginx.yaml

kubectl scale replicaset new-replica-set --replica=4

service : dbservce.dev.svc.cluster.local

kubectl run nginx --image=nginx:alpine --dry-run=client -o yaml > nginx.yaml    # create a pod 

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  -  image: nginx
     name: nginx
  nodeName: node01
```

kubectl get pods --selector app=my-app    # Where app=my-app is a label

kubectl get all --selector env=prod,bu=finance,tier=frontend -o wide

kubectl taint nodes node1 key1=value1:NoSchedule				# No pod will be able to schedule on this node until they have a matching toleration

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "key1/"
    operator: "Exists"
    effect: "NoSchedule"
```

```
kubectl rollout status deploymentname -n namespace
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
kubectl rollout restart deployment <deployment name>
kubectl rollout undo myapp-deployment		# to rollback a deployment
kubectl edit deploy <deployment name>
```

docker run dockerfile 15 
docker run dockerfile

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        args:
          - "/bin/bash"
          - "-c"
          - "echo 'Hello, Kubernetes!' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
        ports:
        - containerPort: 80
```


kubectl create configmap my-config --from-literal=foo=bar --dry-run=client -o yaml				# Create a configmap

kubectl create secret tls NAME --cert=path/to/cert/file --key=path/to/key/file  --dry-run=client -o yaml	# Create secret

kubectl autoscale deployment my-app --cpu-percent=50 --min=1 --max=10			# Create a HPA, prefer the definition via deployments

```
export ETCDCTL_API=3
etcdctl snapshot save snapshot.db
ls 
	snapshot.db
etcdctl snapshot status snapshot.db
	--> give back infos about the snapshot (hash, revision, total keys, total size)
```

openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -sub "/CN=KUBERNETES-CA" -out ca.csr
openssl x509 -req -in ca.csr --signkey ca.key -out ca.crt

```
curl https://kube-apiserver:6443/api/v1/pods \
     --key admin.key \
     --cert admin.crt \
     --cacert ca.crt
```

cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i crt | grep tls-cert-file		# certificate file used for the kube-api server
ssh controlplane
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i crt | grep -i etcd-certfile		# Certificate file used to authenticate kube-apiserver as a client to ETCD Server
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i key | grep -i kubelet-client	# key used to authenticate kubeapi-server to the kubelet server
cat /etc/kubernetes/manifests/etcd.yaml | grep -i crt | grep -i cert-file			# ETCD Server Certificate used to host ETCD server.
cat /etc/kubernetes/manifests/etcd.yaml | grep -i crt | grep -i trusted-ca-file			# ETCD Server CA Root Certificate used to serve ETCD Server

openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -i "CN" | grep -i Subject

cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i crt | grep -i tls-cert-file
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -i "CN" | grep -i Issuer


akshay.key  -> private key generated by akshay (we are not supposed to have it) 
akshay.csr  -> the CSR of akshay to get his certificate
`cat myuser.csr | base64 | tr -d "\n" > csr_on_one_line`

Then
```
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myuser # example
spec:
  # This is an encoded CSR. Change this to the base64-encoded contents of myuser.csr
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZVzVuWld4aE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQTByczhJTHRH>
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
```
Then
```
kubectl -f myuser_csr.yaml
```
Then
```
kubectl get csr
kubectl get csr/myuser -o yaml   # just to check about the requests 
kubectl certificate approve myuser
```
OR if we want to reject
```
#Let's guess that we would like to reject it : 
kubectl certificate deny myuser
kubectl delete certificate myuser
```
Then
```
kubectl get csr myuser -o jsonpath='{.status.certificate}'| base64 -d > myuser.crt
```



Make a pod able to pull from local registry
```
docker-registry

kubectl create secret docker-registry private-reg-cred --docker-username=dock_user --docker
-password=dock_password --docker-server=myprivateregistry.com:5000 --docker-email=dock_user@myprivateregistry.com
```
Add in pod template part of a deployment
```
  imagePullSecrets:
  - name: regcred
```

learn netpol



docker run -it --name mysql --volume-driver rexray/ebs --mount src=ebs-vol,target=/var/lib/mysql mysql

docker run --mount type=bind,source=data/mysql,target=/var/lib/mysql mysql


```
    apiVersion: v1
    kind: Pod
    metadata:
      name: mypod
    spec:
      containers:
        - name: myfrontend
          image: nginx
          volumeMounts:
          - mountPath: "/var/www/html"
            name: mypd
      volumes:
        - name: mypd
          persistentVolumeClaim:
            claimName: myclaim
```


kubectl get persistentvolumeclaim --> It's pending
kubectl get persistentvolume --> It's available

```
kustomize create --autodetect

# If there are yaml files in the current directory a "ressource" tag listing all the yamls files are done
```




