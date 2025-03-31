CKA-2025

**COURSE** https://github.com/kodekloudhub/certified-kubernetes-administrator-course


Disclaimer : I'm not the creator of thoses tests, I'm working for the certification myself with them.

Certified Kubernetes Administrator: https://www.cncf.io/certification/cka/

Exam Curriculum (Topics): https://github.com/cncf/curriculum

Candidate Handbook: https://www.cncf.io/certification/candidate-handbook

Exam Tips: http://training.linuxfoundation.org/go//Important-Tips-CKA-CKAD


https://github.com/kodekloudhub/certified-kubernetes-administrator-course


K3S : https://k3s.io/


https://uklabs.kodecloud.com/courses/labs-certified-kubernetes-administrator-with-practice-tests/




# know about

- admission controller and admission API
- imperative commands like kubectl run, kubectl create -> convert ingress to gateway API /!\
- know about api gateway which replaced ingress  + ingress to api gateway
- mutating webhook
- do exams on PSIExam && KillerSH --> apparemment KillerSH sont derrière PSI donc le + important == PSI
- liveness probe
- readiness probe
- gateway API and TLS /!\
- know to properly investigate kubelet
- know role, and role bindings
- Being able to deploy a network add (CNI) as calico for example



# Command to be known

kubectl create namespace new-namespace
kubectl create secret
kubectl create configmap
kubectl run nginx --image=nginx  # to create a pod
kubectl scale...
kubectl create clusterrole storage-admin --resource=persistentvolumes,storageclasses --verb=list,create,get,watch
kubectl api-resources # to know the group in apiGroup, for example for clusterrole
kubectl create clusterrolebinding michelle-storage-admin --user=michelle --clusterrole=storage-admin
kubectl get storageclass --as michelle
