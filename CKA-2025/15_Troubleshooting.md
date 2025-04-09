# Troubleshooting

## Application failure
https://uklabs.kodekloud.com/topic/practice-test-application-failure-2/

Mostly modifications of components like services, deployments etc...

https://uklabs.kodekloud.com/topic/practice-test-control-plane-failure-2/

Mostly modifications around kube-system controlplane pods through /etc/kubernetes/*** on the controlplane, think about looking at the logs of the pods in kube-system

https://uklabs.kodekloud.com/topic/practice-test-worker-node-failure-2/

Mostly about node
ssh on node
then check the kube related services on the node
journalctl -u kubelet
systemctl status kubelet

Keep in mind that if you can most config files in `/etc/kubernetes/` you also have config files in `/var/lib/kubelet/`

Port admin for worker to authenticate to the controlplane : https://controlplane:6443/blablabla

Do not forget to restart the kubelet service `systemctl restart kubelet` if you modify /etc/kubernetes/kubelet.conf

Given for the next lab :

To install weavenet :
```
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```
About netpols : 
https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy

Network lab :
https://uklabs.kodekloud.com/topic/practice-test-troubleshoot-network-2/

It's a little sad, since you have to know specifically about Weavenet which is clearly not the standard.

For the second question
```
kubectl get pods -n kube-system
# pod kube-proxy is dead
kubectl logs -f kube-proxy-lcr65 -n kube-system
# config file no such file or directory
We know that the correct file is /var/lib/kube-proxy/config.conf
We edit the kube-proxy daemonset to change the path as following 

spec:
    containers:
    - command:
        - /usr/local/bin/kube-proxy
        - --config=/var/lib/kube-proxy/config.conf
        - --hostname-override=$(NODE_NAME)

ET VOILA !
```

But this lab was a little broken.
