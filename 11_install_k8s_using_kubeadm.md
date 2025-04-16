# Installing Kubernetes using KubeADM

![Architecture KubeADM](./pictures/architecturekubeadm.png)

Require to have VM existing before installation

Vagrant file to provision VMs : https://github.com/kodekloudhub/certified-kubernetes-administrator-course


installation via kubeadm, documentation : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/


```
## The source is based on virtualbox, we could image have the same about Hyper-V
vi Vagrantfile
## customiser la plateforme
vagrant status (in the directory that contain the Vagrantfile)
vagrant up

## Then deploy k8s cluster using kubeadm
## mono master : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
## OR
## multiple master : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/

```
**The whole explaination is obsolete, we decide to search for another source** : https://www.mirantis.com/blog/how-install-kubernetes-kubeadm/


## Practice

https://uklabs.kodekloud.com/topic/practice-test-cluster-installation-using-kubeadm/

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl

Define repositories

```
on each node
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
```

then install controlplanes / masters

```
kubeadm installed on controlplane
kubelet installed on controlplane

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl		# Optional - forbid later update - lock the version
```

then install workers

```
Kubeadm installed on worker node01
Kubelet installed on worker node01

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl		# Optional - forbid later update - lock the version
```

then go back on the control-plane
```
IP_ADDR=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address $IP_ADDR --pod-network-cidr=172.17.0.0/16 --service-cidr=172.20.0.0/16
```

You get the info to bind workers to the control plane DO NOT PLAY IT ON MASTER NODE, it's useless, it's made for worker

```
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.183.235:6443 --token 67h6sh.a7n9czafhl17hzoy \
        --discovery-token-ca-cert-hash sha256:90868311bc21437d07efd9ae3c6f5ca4a6a7c3c35b5651137dc646609056f150 

OR you can regenerate it by playing

root@controlplane:~> kubeadm token create --print-join-command
kubeadm join 192.168.114.75:6443 --token aqe7sk.zyr2zpqxa0aomjje --discovery-token-ca-cert-hash sha256:b9fa5652e076b79889b7ceb2f41638be5d6975c2c2970b27ed6c9e601315cd41
```

then to get the default kube-config

`cp /etc/kubernetes/admin.conf ~/.kube/config`

And you can try to deploy a CNI (Container Network Interface, typically flannel, calico etc...)

`kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml`


## If you need to upgrade

First you update kubeadm on a first controlplane/master

```
sudo apt update
sudo apt-cache madison kubeadm

sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm='1.31.x-*' && \
sudo apt-mark hold kubeadm

kubeadm version

sudo kubeadm upgrade plan

sudo kubeadm upgrade apply v1.31.x
```

Then update the CNI plugin 

```
depending of the CNI installed
```

Then for the other controlplanes , do the same, but instead of `kubectl upgrade apply` play the following line

```
sudo kubeadm upgrade node
```

Then for each worker node

```
# drain node
kubectl drain <node-to-drain> --ignore-daemonsets

# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet='1.31.x-*' kubectl='1.31.x-*' && \
sudo apt-mark hold kubelet kubectl

# restart the kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# uncordon the node with the name of your node
kubectl uncordon <node-to-uncordon>

```
