# Basic Microservice

## Lab: Configure Helm, deploy the "Basic Microservice" Helm chart

// TODO MKN: elaborate more

```shell
../helm-basic.sh deploy
```

### Verify "Basic Microservice" is working

#### From inside the Cluster

```shell
kubectl run pod-in-kube -it --rm --image=michaelkubecourse/tools --restart=Never  

# your-svc.your-namespace.svc.cluster.local
# root@pod-in-kube:/course# 
curl http://basic.apps.svc.cluster.local:8080/hello?myName=John; echo

# The expected result:
#   Hello John!

```

#### From your local Computer

```shell
# Establish port forwarding from you local computer to the "basic" service in the EKS cluster
../../port-forward-basic-workload.sh.sh

# Open in browser: 
#   http://localhost:8080/hello?myName=John

# The expected result:
#   Hello John!
```
