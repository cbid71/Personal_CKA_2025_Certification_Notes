# Security

![Objectives](./pictures/objectives.png)


## First elements

first thing to control : who can access to kube-apiserver

### Authentication
Who are you ?

- files - username and password
- files - username and tokens
- certificates
- external authentication provider (ex: LDAP)
- service account  (mostly for machine authentication)

Several kind of users
- admins
- developers
- bots

#### Authentication through files - DEPRECATED


About admin/developers -> they authenticate to the kube-apiserver 

Users can basically connect with a csv containing login/password

You can pass a csv as file to the kube-apiserver allowing a list of users.

```
$ kubectl exec -it kube-apiserver-kind-control-plane -n kube-system /bin/sh
# cd /etc/kubernetes/api-server-basic-auth-files
# cat users.csv
somepassword,johndoe,johndoe123,developers
# password,user,uniqueid,group
```

Of course the password can be on the format of tokens.

```
$ k describe pods kube-apiserver-kind-control-plane -n kube-system
Name:                 kube-apiserver-kind-control-plane
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 kind-control-plane/172.17.0.4
Start Time:           Fri, 24 Apr 2020 22:45:24 +0530
Labels:               component=kube-apiserver
                      tier=control-plane
Annotations:          kubernetes.io/config.hash: d062ea78249b6b8fc690545baa6ba62d
                      kubernetes.io/config.mirror: d062ea78249b6b8fc690545baa6ba62d
                      kubernetes.io/config.seen: 2020-04-24T17:15:18.9986624Z
                      kubernetes.io/config.source: file
Status:               Running
IP:                   172.17.0.4
IPs:                  <none>
Containers:
  kube-apiserver:
    Container ID:  containerd://7c5842a213a419cde18bf4a07b6a49c98e34e8ec5001baabb07501e85f57158a
    Image:         k8s.gcr.io/kube-apiserver:v1.14.10
    Image ID:      sha256:753b038620e6ffd32c32313cfe4b42d78b52f27f40ee9a0134bc47cf60a04556
    Port:          <none>
    Host Port:     <none>
    Command:
      kube-apiserver
      --advertise-address=172.17.0.4
      --allow-privileged=true
      --authorization-mode=Node,RBAC
      --basic-auth-file=/etc/kubernetes/api-server-basic-auth-files/users.csv
      --client-ca-file=/etc/kubernetes/pki/ca.crt
      --enable-admission-plugins=NodeRestriction
....
```

We can see the parameter --basic-auth-file for csv, replaced by --token-auth-file if the file contains tokens instead of passwords

Source : https://github.com/kubernetes-sigs/kind/issues/1507

And to authenticate through token

`curl -v -k https://master-node-ip:6443/api/v1/pods --header "Authorization: Bearer tokentokenteoktnejfjshfkshfkjsbfksjf"`


- This mechanism is NOT recommended
- Consider volume mount while providind the file in a kubeadm setup
- Setup a role based authorization for the new users

### Authorization
What are you allowed to do ?

- RBAC
- ABAC
- Node Authorization
- Webhook mode

## TLS certificate

Certificates in a K8s cluster :

![Certificate](./pictures/tlscertificate.png)

### Basics

- Symetric encryption (shared key)
- Assymetric encryption (private key and public key)
- hybrid encryption (a symetric key is encrypted with the public key of the destinator, then sent to the destinator)

Certificate is a public key + other informations, generally created by a well known authentication company named a Certificate Authority, that will act as an intermediation between the user and a customer.
The Certificate Authority will verify the company asking for a certificate before to give it a certificate.

The certificate will contain the information by both the certificate authority and the owner of the certificate -> that is named a "certificate chain".

### TLS in Kubernetes

Certificate authority -> root certificate

Machine with its public and private certificate -> Server/Serving certificate

A server can ask a client to authenticate himself using certificate -> Client certificates

Certificate ( public key )
- *.crt
- *.pem

Private Key
- *.key
- *-key.pem

All component have a pair

![TLS](./pictures/tls2.png)

- kube-api server : apiserver.crt AND apiserver.key
- etcd server : etcdserver.crt AND etcdserver.key
- kubelet server, on each worker node : kubelet.crt AND kubelet.key

![Certificate flow](./pictures/certificateflow1.png)

It's too many certificates

![Certificate groups](./pictures/certificateflow2.png)

Let's make it simplier

![Certificate simplier](./pictures/certificateflow3.png)

### Certificate creation



Generate private key

`openssl genrsa -out ca.key 2048`

Generate certificate signing request (CSR) -> that the kind of stuff you send to a certificate authority

`openssl req -new -key ca.key -sub "/CN=KUBERNETES-CA" -out ca.csr`

Sign the CSR to get a certificate -> that's what does a certificate authority

`openssl x509 -req -in ca.csr --signkey ca.key -out ca.crt`

In this case we have signed our CSR file with our own private key (self-signed)

Then we get a certificate for KUBERNETES-CA, validated by us (by a certificate authority in real life)

For K8s we will manage two kinds of certificates :
- "client" certificates that will be used to send requests
- "server" certificates that will be used to receive requests 


FIRST WE PROCEED TO CREATE CERTIFICATE TO SEND REQUESTS

Using our keys and our whole knew certificate we will be able to do a pair of keys + a certificate for each of 
- the admin user
- the scheduler
- the controller manager
- the kube-proxy
- kube-api server to connect to kubelets
- kube-api server to connect to etcd server
- kubelet (different on each node) to connect to other kubelets

THEN we will later proceed differently to create additional pair of keys + certificates for 
- the etcd server
- kube-api server to receive requests
- kubelet (different for each node) to receive requests

![All certificates](./pictures/allcertificates.png)

Keep in mind that the different k8s components are configured to be requested only if you can prove who you are.
A certificate and a private key will help us prove who we are.
Since we are playing with self-signed certificates we can eventually have a warning while requesting.
But for now as admin we can authenticate to those components and request them

```
curl https://kube-apiserver:6443/api/v1/pods \
     --key admin.key \
     --cert admin.crt \
     --cacert ca.crt

# admin key = our private key
# cert = our certificate
# cacert = the public certificate from the certificate authority/ca-root
```

Here an example of kubeconfig that is using the same mechanism under yaml format :

![Kube-config example](./pictures/kubeconfigexample.png)

Reminder : certificate authorities (CA) are usually widely known BUT if it's not the case, you have to copy the public certificate of the Certificate Authority / ca-root on each component.

- admin
- scheduler
- controller-manager
- kube-proxy
- kube-api server
- kubelet
- etcd server


THEN WE PROCEED TO CREATE CERTIFICATIONS FOR SERVER SIDE in charge of receiving requests

- 
- A key pair for each ETCD node of the ETCD cluster
- A certificate per ETCD node

TODO : find an example of etcd.yaml / etcd service which include properly the parameters for key files and cert files
The following parameter capture is not enough

![ETCD](./pictures/etcd.png)


### Certificate details

To manage certificates
- modifying the kube-apiserver.service
OR 
- kubeadm (just like to install the plateform and update the control plane or the kube-api server)

Two different ways of maintaining the certificates :

![Two different ways of maintaining the certificates](./pictures/cert2ways.png)

Since then you will manage MANY certificates through a modification of manifests in the kube controller pod/machine.

**YES there are many lines to understand**

![example of modification of certificates for kube-api server](./pictures/modifycertificates.png)

Certificates details :

`openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout`

Event for invalid cert : 

![Event for invalid cert](./pictures/eventforinvalidcert.png)

Can also been seen through `kubectl logs -f ****kube-api**** -n kube-system` 



You can start making lists of certificates before creating them.

![Example of document to classify certificates](./pictures/example_of_document_to_list_certificates.png)

![Example of document to classify certificates - 2](./pictures/example_of_document_to_list_certificates_2.png)

### Practices

https://uklabs.kodekloud.com/topic/practice-test-view-certificate-details-2/

Note : for this whole infrastructure, the creator created a origine "kubernetes" certificate.

Identify the certificate file used for the kube-api server
```
ssh controlplane
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i crt | grep tls-cert-file
```

Identify the Certificate file used to authenticate kube-apiserver as a client to ETCD Server.
```
ssh controlplane
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i crt | grep -i etcd-certfile
```

Identify the **key** used to authenticate kubeapi-server to the kubelet server.
```
ssh controlplane
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i key | grep -i kubelet-client
```

Identify the ETCD Server Certificate used to host ETCD server.
```
ssh controlplane
cat /etc/kubernetes/manifests/etcd.yaml | grep -i crt | grep -i cert-file
```

Identify the ETCD Server CA Root Certificate used to serve ETCD Server.
```
ssh controlplane
cat /etc/kubernetes/manifests/etcd.yaml | grep -i crt | grep -i trusted-ca-file
```

What is the Common Name (CN) configured on the Kube API Server Certificate?
```
ssh controlplane
# get the path to the cert
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i crt | grep -i tls-cert-file     

openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -i "CN" | grep -i Subject
```

What is the name of the CA which issued the certificate ?
```
ssh controlplane
# get the path to the cert
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i crt | grep -i tls-cert-file        

openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -i "CN" | grep -i Issuer
```

Which of the below alternate names is not configured on the Kube API Server Certificate?
```
ssh controlplane
# get the path to the cert
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i crt | grep -i tls-cert-file 

openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | more
# Then identify the chapter 
            X509v3 Subject Alternative Name: 
                DNS:controlplane, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.
default.svc.cluster.local, IP Address:172.20.0.1, IP Address:192.168.242.160
```

What is the Common Name (CN) configured on the ETCD Server certificate?
```
ssh controlplane
# get the path
cat /etc/kubernetes/manifests/etcd.yaml | grep -i crt | grep -i cert-file

openssl x509 -in /etc/kubernetes/pki/etcd/server.crt -text -noout  | grep -i CN | grep -i Subject
```

How long, from the issued date, is the Kube-API Server Certificate valid for? (path to the cert is given)
```
ssh controlplane
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | more
# Then check for the validity chapter
        Validity
            Not Before: Mar 26 17:07:42 2025 GMT
            Not After : Mar 26 17:12:42 2026 GMT
```

How long, from the issued date, is the Root CA Certificate valid for? (given path)
Answer : same process as former question
```
openssl x509 -in /etc/kubernetes/pki/ca.crt -text -noout | more
```

Documentation : https://kubernetes.io/docs/tasks/administer-cluster/certificates/

Kubectl suddenly stops responding to your commands. Check it out! Someone recently modified the /etc/kubernetes/manifests/etcd.yaml file
You are asked to investigate and fix the issue. Once you fix the issue wait for sometime for kubectl to respond. Check the logs of the ETCD container.


```
First thing first, no answer from the kubectl commands
kubectl get pods
.......... impossible to connect

We are on the controlplane, it's not very realistic BUT we can use 'docker ps -a' to check pods on the current node... yes in a real life scenario when your cluster has 100 nodes it can't be done, but let guess

docker ps -a | grep -i kube-apiserver

- Both etcd and kube-apiserver ARE exited

Let's check the logs from the first KO pod 

docker logs 2245a8855

---> kubeapi-server can't connect to the port 2379 --> It can't connect to the ETCD, dso it's a problem with ETCD cluster.

Ok let's check the logs from the etcd pod

docker logs 55784c45

Error missing file /etc/kubernetes/pki/etcd/server-certificate.crt

Let's look at the content of "ls /etc/kubernetes/pki/etcd/"

- ....
- server.key 
- server.crt

cat /etc/kubernetes/manifests/etcd.yaml | grep -i cert
   - --cert-file=/etc/kubernetes/pki/etcd/server-certificate.crt
...

Here it's a little dumb, but the answer is only to change the content of the variable 

   - --cert-file=/etc/kubernetes/pki/etcd/server.crt

Then wait a few minutes

That's all folks !

```

Ok but it broke a few hours laters, why ?

```
ok let's go back to the controlplane :

ssh controlplane

docker ps -a | grep -i kube-api-server

---> it's broken, let's look at the logs of the kube-api server

docker logs 2154c5421

"https://127.0.0.1:2379 Error aauthentication failed x509 certificate signed by unknown authority"

Let's look at the logs from the etcd pod

docker logs 444c555

' rejected connection bad certificate "", servername "" '

ok a log of a rejected connection from somewhere due to a failed certificate, let's take a look at certificates between kube-api server and etcd.

cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -i "\-\-etcd"

- --etcd-cafile=/etc/kubernetes/pki/ca.crt
- --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
- --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
- --etcd-servers=https://127.0.0.1:2379

By the solution, the file /etc/kubernetes/pki/ca.crt doesn't exists, we have to replace it with /etc/kubernetes/pki/etcd/ca.crt


That's all folks !
```
---

MY OWN SOLUTION - Not exactly true by what was expected

```

/etc/kubernetes/pki/etcd/server-certificate.crt does not exists, it has possibly been removed

private key = /etc/kubernetes/pki/etcd/server.key

Recreate a CSR from this key 
openssl req -new -key /etc/kubernetes/pki/etcd/server.key -sub "/CN=controlplane" -out server.csr

then recreate the crt

openssl x509 -req -in server.csr \
     -CA /etc/kubernetes/pki/etcd/ca.crt \
     -CAkey /etc/kubernetes/pki/etcd/ca.key \
     -CAcreateserial \
     -out /etc/kubernetes/pki/apiserver-etcd-client.crt

openssl x509 -req -in server.csr \
     -CA /etc/kubernetes/pki/etcd/ca.crt \
     -CAkey /etc/kubernetes/pki/etcd/ca.key \
     -CAcreateserial \
     -out /etc/kubernetes/pki/etcd/server-certificate.crt


UNFINISHED
```

---


## Certificate API

It's recommended to the Admin to have its own private key & certificate to connect to the cluster
When a new Admin arrive, she has to 
- create her own private key, 
- generate her CSR from her key
- send the CSR to the existing Admin user

Then the existing Admin has to 
- use the CSR and the appropriate files from the cluster to get a certificate
- send the certificate back to the new Admin

Once she got the certificate, and so she will be able to connect to the cluster.

## Practice

https://uklabs.kodekloud.com/topic/practice-test-certificates-api-2/


So we have a new admin :

```
akshay.key  -> private key generated by akshay (we are not supposed to have it) 
akshay.csr  -> the CSR of akshay to get his certificate
```
Documentation about management of keys, csr and certificates : https://kubernetes.io/docs/tasks/administer-cluster/certificates/

To get a certificate from a CSR we can do it by openssl, or we can do it in a fun way by asking K8s to generate it


/!\ Documentation : https://kubernetes.io/docs/tasks/tls/certificate-issue-client-csr/#create-k8s-certificatessigningrequest


Let's guess we have myuser.csr

```
cat myuser.csr | base64 | tr -d "\n" > csr_on_one_line
```
Then
```
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myuser # example
spec:
  # This is an encoded CSR. Change this to the base64-encoded contents of myuser.csr
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZVzVuWld4aE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQTByczhJTHRHdTYxakx2dHhWTTJSVlRWMDNHWlJTWWw0dWluVWo4RElaWjBOCnR2MUZtRVFSd3VoaUZsOFEzcWl0Qm0wMUFSMkNJVXBGd2ZzSjZ4MXF3ckJzVkhZbGlBNVhwRVpZM3ExcGswSDQKM3Z3aGJlK1o2MVNrVHF5SVBYUUwrTWM5T1Nsbm0xb0R2N0NtSkZNMUlMRVI3QTVGZnZKOEdFRjJ6dHBoaUlFMwpub1dtdHNZb3JuT2wzc2lHQ2ZGZzR4Zmd4eW8ybmlneFNVekl1bXNnVm9PM2ttT0x1RVF6cXpkakJ3TFJXbWlECklmMXBMWnoyalVnald4UkhCM1gyWnVVV1d1T09PZnpXM01LaE8ybHEvZi9DdS8wYk83c0x0MCt3U2ZMSU91TFcKcW90blZtRmxMMytqTy82WDNDKzBERHk5aUtwbXJjVDBnWGZLemE1dHJRSURBUUFCb0FBd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBR05WdmVIOGR4ZzNvK21VeVRkbmFjVmQ1N24zSkExdnZEU1JWREkyQTZ1eXN3ZFp1L1BVCkkwZXpZWFV0RVNnSk1IRmQycVVNMjNuNVJsSXJ3R0xuUXFISUh5VStWWHhsdnZsRnpNOVpEWllSTmU3QlJvYXgKQVlEdUI5STZXT3FYbkFvczFqRmxNUG5NbFpqdU5kSGxpT1BjTU1oNndLaTZzZFhpVStHYTJ2RUVLY01jSVUyRgpvU2djUWdMYTk0aEpacGk3ZnNMdm1OQUxoT045UHdNMGM1dVJVejV4T0dGMUtCbWRSeEgvbUNOS2JKYjFRQm1HCkkwYitEUEdaTktXTU0xMzhIQXdoV0tkNjVoVHdYOWl4V3ZHMkh4TG1WQzg0L1BHT0tWQW9FNkpsYWFHdTlQVmkKdjlOSjVaZlZrcXdCd0hKbzZXdk9xVlA3SVFjZmg3d0drWm89Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
```
Then
```
kubectl -f myuser_csr.yaml
```
Then
```
kubectl get csr
kubectl get csr/myuser -o yaml   # just to check about the requests 
kubectl certificate approve myuser
```
OR if we want to reject
```
#Let's guess that we would like to reject it : 
kubectl certificate deny myuser
kubectl delete certificate myuser
```
Then
```
kubectl get csr myuser -o jsonpath='{.status.certificate}'| base64 -d > myuser.crt
```
Then send that certificate back to the new user

