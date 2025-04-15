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

