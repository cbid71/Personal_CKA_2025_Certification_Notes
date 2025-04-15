# Other topics

In the upcoming lecture we will explore some advanced commands with kubectl utility. But that requires JSON PATH. If you are new to JSON PATH queries get introduced to it first by going through the lectures and practice tests available here.

https://kodekloud.com/p/json-path-quiz

Once you are comfortable head back here:

I also have some JSON PATH exercises with Kubernetes Data Objects. Make sure you go through these:

https://mmumshad.github.io/json-path-quiz/index.html#!/?questions=questionskub1

https://mmumshad.github.io/json-path-quiz/index.html#!/?questions=questionskub2


Json allows data of 100s of nodes and 1000s of pods deployments and replicasets descriptions

Remember : `kubectl get nodes` discuss with `kube-apiserver`
```
# get pods
kubectl get pods -o json
#get all images from all pods
kubectl get pods -o=jsonpath=".items[0].spec.containers[0].image"
# get  names from all nodes 
kubectl get nodes -o=jsonpath='{.items[*].metadata.name}'
# get name for all pods + its associated image (a line per Name + image)
kubectl get pod -o=jsonpath='{items[*].medatadata.name} {items[*].spec.containers[0].image}'
```

## Practice

https://uklabs.kodekloud.com/topic/practice-test-advanced-kubectl-commands-2/

```
    1  kubectl get nodes -o json > /opt/outputs/nodes.json
    2  kubectl get node node01 -o json > /opt/outputs/node01.json
    8  kubectl get nodes -o=jsonpath='{.items[*].metadata.name}' > /opt/outputs/node_names.txt
    9  kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}' > /opt/outputs/nodes_os.txt
   10  kubectl config view --kubeconfig=my-kube-config  -o jsonpath="{.users[*].name}" > /opt/outputs/users.txt
   11  kubectl get pv --sort-by=.spec.capacity.storage > /opt/outputs/storage-capacity-sorted.txt
   12  kubectl get pv --sort-by=.spec.capacity.storage -o=custom-columns=NAME:.metadata.name,CAPACITY:.spec.capacity.storage > /opt/outputs/pv-and-capacity-sorted.txt
   13  kubectl config view --kubeconfig=my-kube-config -o jsonpath="{.contexts[?(@.context.user=='aws-user')].name}" > /opt/outputs/aws-context-name
```



