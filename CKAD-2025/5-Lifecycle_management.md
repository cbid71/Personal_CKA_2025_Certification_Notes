# Lifecycle management

## Rolling update and rollbacks

```
kubectl rollout status deploymentname -n namespace
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
kubectl rollout restart deployment <deployment name>
kubectl rollout ????				# Update de deployemtn -> there are other better options
kubectl rollout undo myapp-deployment		# to rollback a deployment
kbuectl edit deploy <deployment name>

```


## Practice

https://uklabs.kodekloud.com/topic/practice-test-rolling-updates-and-rollbacks-2/


## Configurations

- command and arguments
- configmap/secrets/...
- environment variables

Check at the docker file, you have cmd file in the end of the dockerfile

![DockerFile Example](./pictures/dockefileexample.png)

```
FROM ubuntu

CMD command param
```

OR

```
FROM ubuntu

CMD ["command","param"]
```

BUT DO NOT USE

```
FROM ubuntu
CMD "command param"
```

CMD in the end of a dockerfile can be overloaded 

```
FROM ubuntu
CMD sleep 5
```

`CMD` Can be overloaded with `docker run dockerfile sleep 10`

The other possibility is `Entrypoint`

```
FROM ubuntu
entrypoint sleep
```

`Entrypoint` is meant to be concatenated before the parameters that you would pass

```
docker run dockerfile 15

# Command at startup "sleep 15"
```

You can choose to have both Entrypoint and CMD

```
FROM ubuntu
ENTRYPOINT["sleep"]
CMD["5"]
```

This will provide you a default behaviour can you can overload

```
docker run dockerfile # ----> will have a default startup command 'sleep 5'
docker run dockerfile 15 # -> will have a startup command 'sleep 15'
```

## Argument

Documentation page : https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/

A pod : 
```
apiVersion: v1
kind: Pod
metadata:
  name: command-demo
  labels:
    purpose: demonstrate-command
spec:
  containers:
  - name: command-demo-container
    image: debian
    command: ["printenv"]
    args: ["HOSTNAME", "KUBERNETES_PORT"]
  restartPolicy: OnFailure
```

A deployment :
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


## Practices

https://uklabs.kodekloud.com/topic/practice-test-commands-and-arguments-2/

To see commands on startup of a pod

`kubectl describe pod` then look at "command" part of the description.

Remember **args** HAVE TO be **array of strings**

```
apiVersion: v1 
kind: Pod 
metadata:
  name: ubuntu-sleeper-2 
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    args:
     - "sleep"
     - "5000"
```

It seem that specifying `command` as parameter in a deployment overload both CMD and ENTRYPOINT.
But I have different informations depending of the source. TODO : find the real answer

```
apiVersion: v1 
kind: Pod 
metadata:
  name: ubuntu-sleeper-2 
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: "python pouet.py"			# -> will ignore ENTRYPOINT ?? I disagree, I have to test
    args:					# -> args will concat after an ENTRYPOINT or overload a CMD ?
     - "--color"
     - "green"
```

## Environment variables


Simple environement variable

```
apiVersion: v1
kind: Pod
metadata:
  name: envar-demo
  labels:
    purpose: demonstrate-envars
spec:
  containers:
  - name: envar-demo-container
    image: gcr.io/google-samples/hello-app:2.0
    env:
    - name: DEMO_GREETING
      value: "Hello from the environment"
    - name: DEMO_FAREWELL
      value: "Such a sweet sorrow"

```



From another variable value

https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-envars-fieldref
spec:
  containers:
    - name: test-container
      image: registry.k8s.io/busybox:1.27.2
      command: [ "sh", "-c"]
      args:
      - while true; do
          echo -en '\n';
          printenv MY_NODE_NAME MY_POD_NAME MY_POD_NAMESPACE;
          printenv MY_POD_IP MY_POD_SERVICE_ACCOUNT;
          sleep 10;
        done;
      env:
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: MY_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: MY_POD_SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName
  restartPolicy: Never

```


As a configmap keyref

https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

Configmap side : 
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  special.how: very
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: env-config
  namespace: default
data:
  log_level: INFO
```

Create an environment variable from the content of a configmap (configmapkeyref)
```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: registry.k8s.io/busybox:1.27.2
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.how
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: env-config
              key: log_level
  restartPolicy: Never
```

Create an environement variable list from the whole content of a configmap

configmap
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  SPECIAL_LEVEL: very
  SPECIAL_TYPE: charm

```

the whole list of variables in the configmap will be seen as env variables
```
apiVersion: v1
 kind: Pod
 metadata:
   name: dapi-test-pod
 spec:
   containers:
     - name: test-container
       image: registry.k8s.io/busybox
       command: [ "/bin/sh", "-c", "env" ]
       envFrom:
       - configMapRef:
           name: special-config
   restartPolicy: Never
 
```

A configmap can be seen as a volume, then mounted on a specific directory :

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  SPECIAL_LEVEL: very
  SPECIAL_TYPE: charm
```

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: registry.k8s.io/busybox:1.27.2
      command: [ "/bin/sh", "-c", "ls /etc/config/" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        # Provide the name of the ConfigMap containing the files you want
        # to add to the container
        name: special-config
  restartPolicy: Never
```

a few commands : 
`kubectl create config <configname> --from-litteral=<key>=<value> `
`kubectl create config <configname> --from-file=<file path> `



## Practices

https://uklabs.kodekloud.com/topic/practice-test-env-variables-2/


## Configure Secrets in Applications

a few commands : 
`kubectl create secret generic <configname> --from-litteral=<key>=<value> `
`kubectl create secret generic <configname> --from-file=<file path> `

Nothing exotic here, read the documentation : https://kubernetes.io/docs/concepts/configuration/secret/

It really works like configmaps with a few specific keywords for references

https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#configure-all-key-value-pairs-in-a-secret-as-container-environment-variables

https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#configure-all-key-value-pairs-in-a-secret-as-container-environment-variables

```
apiVersion: v1
kind: Secret
metadata:
  name: dotfile-secret
data:
  .secret-file: dmFsdWUtMg0KDQo=
---
apiVersion: v1
kind: Pod
metadata:
  name: secret-dotfiles-pod
spec:
  volumes:
    - name: secret-volume
      secret:
        secretName: dotfile-secret
  containers:
    - name: dotfile-test-container
      image: registry.k8s.io/busybox
      command:
        - ls
        - "-l"
        - "/etc/secret-volume"
      volumeMounts:
        - name: secret-volume
          readOnly: true
          mountPath: "/etc/secret-volume"
```




## Practices

https://uklabs.kodekloud.com/topic/practice-test-secrets-2/

```
kubectl create secret generic db-secret --from-literal DB_Host=sql01 --from-literal DB_User=root --from-literal DB_Password=password123 --dry-run=client -o yaml  > secret.yaml
kubectl apply -f secret.yaml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: webapp-pod
spec:
  containers:
  - name: envars-test-container
    image: kodekloud/simple-webapp-mysql
    envFrom:
    - secretRef:
        name: db-secret
```


## Encypting secret data at REST

TODO : /!\ relisten to the chapter 114 - encryption at REST
It's around the kind `EncryptionConfiguration`

https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/


## Practice

https://uklabs.kodekloud.com/topic/practice-test-multi-container-pods-2/

See name of containers in a pod ==> kubectl describe pod podname | more
And you search for the `containers` chapter

Multi container, one pod

```
apiVersion: v1
kind: Pod
metadata:
  name: yellow
spec:
  containers:
  - name: lemon
    image: busybox
  - name: gold
    image: redis
```

Get some logs !
```
kubectl -n elastic-stack exec -it app -- sh
```


One pod, two container, and one volume+one volume mount

```
apiVersion: v1
kind: Pod
metadata:
  name: two-containers
spec:

  restartPolicy: Never

  volumes:
  - name: shared-data
    emptyDir: {}

  containers:

  - name: nginx-container
    image: nginx
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html

  - name: debian-container
    image: debian
    volumeMounts:
    - name: shared-data
      mountPath: /pod-data
    command: ["/bin/sh"]
    args: ["-c", "echo Hello from the debian container > /pod-data/index.html"]


```

Add sidecar container, in the container chapter of a pod :

```
  - name: sidecar
    image: kodekloud/filebeat-configured
    volumeMounts:
    - mountPath: /var/log/event-simulator
      name: log-volume
```

We did a voluntarly mistake while modifying the pod, to export the pod yaml file, then we modified the exported it with the sidecar.
Then we applied it by forcing it.

```
kubectl replace --force -f modified_with_sidecar.yaml
```





