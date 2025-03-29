# Security Config

## kubeconfig

```
kubectl get pods --config configfile
kubeconfig config view				# display config file
kubectl config current-context 

```



The kubeconfig file is composed of three parts:
- clusters list
- users list (~credentials)
- contexts list (mix of cluster+a user, associated to a name)

kubeconfig example
```
apiVersion: v1
kind: Config
clusters:
  - name: my-cluster
    cluster:
      server: https://192.168.242.160:6443
      certificate-authority: /path/to/ca.crt # Path to the certificate authority (CA) cert
users:
  - name: my-user
    user:
      client-certificate: /path/to/client.crt  # Path to the user/client certificate
      client-key: /path/to/client.key          # Path to the user/client private key
contexts:
  - name: my-context
    context:
      cluster: my-cluster
      user: my-user
      namespace: default
current-context: my-context

```

## Practices

https://uklabs.kodekloud.com/topic/practice-test-kubeconfig-2/

```
cp my-kube-config .kube/config
kubectl config get-contexts
kubectl config use-context research
kubectl config view --minify
```
OR
```
edit ~/.bashrc
add
export KUBECONFIG=/root/my-kube-config
save
Then source ~/.bashrc
```

and the problem was about a wrong path to the cert for the user.


## API Groups

Was about the API of kubernetes

https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.27/#deployment-v1-apps

## Authorization

Authorization != Authentication

Authentication = certificates
Authorization = rights to do some actions

Kubelet is playing with the kube-api server about read and write services.

- Read
  * service
  * endpoint
  * node
  * pod
- Write
  * node status
  * pods status
  * events

You can play with policies to modify rights associated with a role or a user

[Audit policy](./pictures/policy.png)

https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/


Authorization modes associated to the kube-api server

- AlwaysAllow (per default) : Allow all requests to all users
- AlwaysDeny : Deny all requests to all users
- ABAC : policies are created to associate user to policies https://kubernetes.io/docs/reference/access-authn-authz/abac/
- RBAC : You define k8s roles and make users able to assume them https://kubernetes.io/docs/reference/access-authn-authz/rbac/ 
- Webhook : synchronous HTTP callout https://kubernetes.io/docs/reference/access-authn-authz/webhook/
- Node : grants permissions to kubelets based on the pods they are scheduled to run

[Authorization Mode](./pictures/authorizationmode.png)

Documentation : https://kubernetes.io/docs/reference/access-authn-authz/authorization/


## RBAC (Role Based Access Controls)

https://kubernetes.io/docs/reference/access-authn-authz/rbac/

We create a role

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

```

OR a cluster role
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

And you bind a user to the role

```
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
# You can specify more than one "subject"
- kind: User
  name: jane # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```

Subjects can be user, group, or serviceaccount BUT there is no direct way of knowing them, you can't list users, it depends of the environment


There is a commande to check control

```
kubectl auth can-i create deployments
kubectl auth can-i delete nodes
kubectl auth can-i create deployments --as dev-user
kubectl auth can-i delete nodes --as dev-user
kubectl auth can-i create deployments --as dev-user --n mynamespace

```

TODO it's important to understand roles, cluster roles and rolebindings



## Practice RBAC

https://uklabs.kodekloud.com/topic/practice-test-role-based-access-controls-2/
```
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i mode
    - --authorization-mode=Node,RBAC
kubectl get roles
kubectl get roles -A
kubectl describe role kube-proxy -n kube-system
kubectl get rolebinding -n kube-system | grep -i kube-proxy
kubectl describe rolebinding kube-proxy -n kube-system

kubectl auth can-i create pod --as dev-user
no
kubectl auth can-i get pod --as dev-user
no
```
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: developer
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["create", "delete", "list"]
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-user-binding
  namespace: default
subjects:
- kind: User
  name: dev-user # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #this must be Role or ClusterRole
  name: developer # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```

About fixing the roles on the 10th question : it was a problem of missing the resource name "dark-blue-app" pod


```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: "2025-03-27T16:11:46Z"
  name: developer
  namespace: blue
  resourceVersion: "3163"
  uid: cd8f8fea-3b40-40af-a2ea-cb75204789e5
rules:
- apiGroups:
  - ""
  resourceNames:
  - blue-app
  - dark-blue-app
  resources:
  - pods
  verbs:
  - get
  - watch
  - create
  - delete
  - list
- apiGroups:
  - apps
  resourceNames:
  - ""
  resources:
  - deployments
  verbs:
  - get
  - watch
  - create
  - delete
  - list
```


## Cluster Role and Cluster Role Bindings

- cluster role : roles extended to the whole cluster (typically roles about nodes related rights)
- Role binding : link users and roles, related to cluster roles, we will more work with clusterrolebindings

## Practices

https://uklabs.kodekloud.com/topic/practice-test-cluster-roles-2/

kubectl get clusterroles
kubectl get clusterrolebindings
kubectl get clusterroles | wc -l
kubectl get clusterrolebindings | wc -l
Cluster roles are cluster wide and not limited to a certain namespace

What user/groups are the "cluster-admin" role bound to ?
kubectl get clusterrolebindings | grep -i cluster-admin
kubectl describe clusterrolebindings cluster-admin 
---> see for the "Subjects" part

kubectl describe clusterrole cluster-admin
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  *.*        []                 []              [*]
             [*]                []              [*]

===> Means everything !


Give the new user `michelle` the access to the nodes

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: michelleclusterrole
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "watch", "list"]
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: michellecrb
subjects:
- kind: User
  name: michelle # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: michelleclusterrole
  apiGroup: rbac.authorization.k8s.io
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: storage-admin
rules:
- apiGroups: [""]
  resources: ["persistentvolumes"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""]
  resources: ["storageclasses"]
  verbs: ["get", "watch", "list"]
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: michelle-storage-admin
subjects:
- kind: User
  name: michelle # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: storage-admin
  apiGroup: rbac.authorization.k8s.io
```

Just to Create a clusterrole and a clusterrolebindings in imperative way

kubectl create clusterrole storage-admin --resource=persistentvolumes,storageclasses --verb=list,create,get,watch
kubectl create clusterrolebinding michelle-storage-admin --user=michelle --clusterrole=storage-admin


## Service Accounts

**Roles** are associated to users, they allow users to do some stuff
**Service accounts** are associated to pods, they allow pods to do some stuff with the cluster, the default service acccount for pods is "default" and only allow a few elements

The SA is associated to a generated token, untile k8s 1.24 it was stored as a **secret**, now it's purely dynamic, in any case that identify the SA for the cluster ( so it identity the pod)

`kubectl create serviceaccount myserviceaccount-sa`

documentation https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/

```
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: build-robot
```

`TokenRequest` --> the API that works in creating the token, automatically done

## Practice

https://uklabs.kodekloud.com/topic/practice-test-service-accounts-2/

kubectl get sa
kubectl describe sa default
kubectl describe deploy web-dashboard | grep -i image
kubectl describe deploy web-dashboard | grep -i serviceaccount
---> ne retourne rien DONC == serviceaccountname == default
Token mount path on the pod : /var/run/secrets/
kubectl create sa dashboard-sa
kubectl create token dashboard-sa		# create a token but DOES NOT associate it to the dashboard, starting the 1.24 is dynamic and no more associated to a secret

Edit the pod template part of the deployment

```
spec:
  serviceAccountName: build-robot
  automountServiceAccountToken: true
```

The element token could be associated to the service account, but the most "normal" way of working is to associate it to the pod through the component automountServiceAccountToken


## Image security

Nothing exotic, it's just about using a local repository


docker login my-beautif-registry.io/app/pouet
kubectl create secrete docker-registry regcred
  --docker-server=
  --docker-username=
  --docker-password=
  --docker-email=

Documentation : https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

## Practice

https://uklabs.kodekloud.com/topic/practice-test-image-security-2/
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
