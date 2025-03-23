# Scheduling

About the capacity of deploying a pod
Eventually defining which node and how to choose the node

```
nodename: blablabla
```


## Practice

https://uklabs.kodekloud.com/topic/practice-test-manual-scheduling-2/


Example of scheduling on a node named `node01`

```
---
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

Note we can update by replace

```
kubectl replace --force -f nginx.yaml
```

## Labels and selectors

Label : usually report of the object itself

```
metadata:
  labels:
    app: my-app
    environment: production
```

annotation : usually store additional informations

```
metadata:
  annotations:
    description: "This is the production version of the app"
    deployer: "john_doe"
```

Selectors : 

`kubectl get pods --selector app=my-app`

Some objects define a replicaset to allow a bound between an information and its description, it's usually kinds (like replicasets or deployments) which aim to create other kinds (like pods)

Example in the documentation page of deployments : https://kubernetes.io/docs/concepts/workloads/controllers/deployment/


## Practice

https://uklabs.kodekloud.com/topic/practice-test-labels-and-selectors-2/

kubectl get pods --selector env=dev

kubectl get all --selector env=prod -o wide

kubectl get all --selector env=prod,bu=finance,tier=frontend -o wide


## Taints and tolerations

Taint : a way to mark a node then being able to add tolerations on pods that will be scheduled on it.

Toleration : a setting on a pod that will allow it to be scheduled on a node with a matching taint.

`kubectl taint nodes nodename key=value:taint-effet`

Taint effect :
- NoSchedule
- PreferNoSchedule
- NoExecute

Taint effect is what will occure on pods that do NOT tolerate those taints.


Documentation page https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

Example of taint: 
```
kubectl taint nodes node1 key1=value1:NoSchedule

This means that no pod will be able to schedule onto node1 unless it has a matching toleration.
```

Example of toleration:
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
  - key: "example-key"
    operator: "Exists"
    effect: "NoSchedule"
```

## Practices

https://uklabs.kodekloud.com/topic/practice-test-taints-and-tolerations-2/

kubectl taint node node01 spray=mortein:NoSchedule

kubectl run mosquito --image=nginx

kubectl run mosquito --image=nginx --dry-run=client -o yaml

Then with modify to add tolerations

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: bee
  name: bee
spec:
  containers:
  - image: nginx
    name: bee
    resources: {}
  tolerations:
  - key: "spray"
    value: "mortein"
    effect: "NoSchedule"
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

```
# remove a taint on a node
kubectl taint node controlplane node-role.kubernetes.io/control-plane-
```



## Node selector

When `nodename` will make you able to select a node for scheduling based on its name
then `nodeSelector` will make you able to select a node for scheduling based on other criteria like size, cpu, ...

documentation page : https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector

Add a label to a node:

kubectl label nodes nodename labelkey=labelvalue

## Node affinity

An even more advanced way to schedule a pod based on caracteristics of a node a little like nodeSelector

Documentation page : https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/

Allowing a like of values accepted

```
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: In
            values:
            - antarctica-east1
            - antarctica-west1
```

TODO

A simplier comparison of 

- requiredDuringSchedulingIgnoredDuringExecution
- preferredDuringSchedulingIgnoredDuringExecution
- requiredDuringSchedulingRequiredDuringExecution


## Practice

https://uklabs.kodekloud.com/topic/practice-test-node-affinity-3/

kubectl label nodes node01 color=blue

No taint -> a deployment without tolerations can be scheduled on aaaaall nodes


```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blue
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: color
                    operator: In
                    values:
                      - blue
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```


```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: red
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```

TODO : To be retried


kubectl create deployment example --image=nginx --replicas=2  --dry-run=client -o yaml

## Taint and Toleration vs Node affinity

TODO : find another source

## Resource requirement and limits

Nothing very exotic

Documentation pages : 

https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

![Resource CPU limits](./pictures/resourcecpulimits.png)

![Memory CPU limits](./pictures/resourcememorylimits.png)


Manage cpu memory and api resource
https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/
limitrange for cpu
https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/cpu-default-namespace/
limitrange for memory
https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/memory-default-namespace/

Edit a POD

Remember, you CANNOT edit specifications of an existing POD other than the below.

    spec.containers[*].image

    spec.initContainers[*].image

    spec.activeDeadlineSeconds

    spec.tolerations

## Practice

https://uklabs.kodekloud.com/topic/practice-test-resource-limits-2/


OOMKilled => the pod have been killed because the pod ran out of memory


## Daemonsets

Some kind of deployments where a pod is deployed on EACH of ALL nodes of the cluster

![Comparison Daemonsets](./pictures/comparisondaemonsets.png) 

Daemonsets documentation : https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/

## Practice

kubectl get daemonsets -A

https://uklabs.kodekloud.com/topic/practice-test-daemonsets-2/

kubectl describe daemonset kube-flannel-ds -n kube-flannel | grep -i image


extracted from the documentation : 

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      containers:
      - name: fluentd-elasticsearch
        image: registry.k8s.io/fluentd-elasticsearch:1.20
      terminationGracePeriodSeconds: 30
```


## Static pods

static pod : a pod that is directly managed by the kubelet on a node, rather than by the Kubernetes API server or the Kubernetes controller manager.


Example of static pod : see the config file in the kubelet description, the static pod is described in the kubelet configuration file.

![Static pod](./pictures/kubeletandstaticpod.png)


Create static pod : https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/


## Practice

https://uklabs.kodekloud.com/topic/practice-test-static-pods-2/

list static pods : 

kubectl get pods --all-namespaces -o json | jq -r '.items | map(select(.metadata.ownerReferences[]?.kind == "Node" ) | .metadata.name) | .[]'

ANOTHER EASIER WAY TO DO IT : 

When you describe de pod there is a section "OwnerReferences", when the pod static, the owner is "kind:node"

Here an example of kubectl describe pod blablabla

![Example of owner references](./pictures/kindnodeforstaticpod.png)

So a very simple way to detect a static pod is 

```
kubectl describe pod balblabla | grep -i "kind: node"
```

Path for configuration of static configuration : /etc/kubernetes/manifests/

ls /etc/kubernetes/manifests/

kubectl describe pod kube-apiserver-controlplane -n kube-system | grep -i image

```
kubectl run static-busybox --image=busybox -o yaml --dry-run=client --command -- sleep 1000 > static.yaml
```
 
On the destruction of the static pod green-busybox, we were supposed to have a file related to this pod in /etc/kubernetes/manifests/ which wasn't the case.
BUT THAT'S THE TRAP HERE :)

To remove it we 
- see which node hosts the pod
- we ssh on the node
- open the kubelet config file `/var/lib/kubelet/config.yaml` 
- search for the variable `staticPodPath`
- we identify the describer directory `/etc/just-to-mess-with-you` :)
- we go to the directory
- we remove the file `green.yaml`
- we can logout from the host node
The pod will be terminated after a few dozens of seconds. 


## Multiple Schedulers
