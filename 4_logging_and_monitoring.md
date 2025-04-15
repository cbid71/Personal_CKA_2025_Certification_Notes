## Logging and monitoring


- metrics-server   --> Plugin for K8s cluster, expose metrics about the cluster.
- prometheus
- elasticsearch
- Datadog
- Dynatrace
- heapter ==> **Retired product**

- cadvisor -> component of Kubelet (so, each node) for monitoring a node, metrics will be sent to the metrics-server
https://github.com/google/cadvisor
https://github.com/google/cadvisor/blob/master/docs/storage/prometheus.md


To deploy the metrics-server :
```
git clone https://github.com/kubernetes-incubator/metrics-server.git
kubectl apply -f deploy/<version>/

OR

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

On minikube, metrics-server exists as an addon
```
minikube addons enable metrics-server
```

Monitoring

Deploying the metric server will allow to have `top` information.

```
kubectl top node
kubectl top pod
```

Get informations about pods

```
kubectl logs -f <pod name>
kubectl describe pod <pod name>
```

Know about events on the whole cluster

```
kubectl get events
```

## Pratice

https://uklabs.kodekloud.com/topic/practice-test-monitor-cluster-components-2/

```
know memory/cpu consumed by pod with namespace value too
kubectl top pods -A
```

