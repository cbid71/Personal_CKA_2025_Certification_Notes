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
