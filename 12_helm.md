# Helm

Nothing very exotic about Helm

```
helm search hub wordpress		# nobody use it
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo wordpress
helm repo list				# list repos known by helm
helm install wordpress
helm install amaze-surf bitnami/apache	# if you need an installation from a specific repo
helm update wordpress
helm delete wordpress
helm rollback wordpress
helm repo remove hashicorp


helm repo add bitnami https://charts.bitnami.com/bitnami
helm install dazzling-web bitnami/nginx --version 12.0.4
helm upgrade dazzling-web bitnami/nginx --version 18.3.6
helm rollback dazzling-web
```


## Pratice

https://learn.kodekloud.com/user/courses/udemy-labs-certified-kubernetes-administrator-with-practice-tests/module/89833709-d94c-4784-9c57-80f6f8ee4e5a/lesson/da5fa576-a6b2-4066-8d87-22e4a56b0105

Chart version => increase on each modification of charts
app version => increase on each modification of the application deployed by the charts
