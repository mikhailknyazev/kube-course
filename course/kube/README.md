# EKS Provisioning

## Lab: Deploy EKS using the provided Terraform code

### terraform init

In folder `/course/kube`:
```shell
terraform init
```

The expected output:
```
Terraform has been successfully initialized!
```

It should create the following files and folders in `/course/kube/`
```
.terraform
.terraform.lock.hcl
```

### terraform plan & apply

#### plan

```shell
terraform plan
```

The expected result: 4-5 pages with the following in the end:
```
Plan: 37 to add, 0 to change, 0 to destroy.
```

#### apply

```shell
terraform apply -auto-approve
```

The expected result (after like 12 minutes):
```
module.kube.aws_iam_policy.cluster_elb_sl_role_creation[0]: Creating...
module.kube.aws_iam_role.cluster[0]: Creating...
module.vpc.aws_vpc.this[0]: Creating...
...
module.kube.aws_eks_cluster.this[0]: Still creating... [10m30s elapsed]
module.kube.aws_eks_cluster.this[0]: Still creating... [10m40s elapsed]
module.kube.aws_eks_cluster.this[0]: Still creating... [10m50s elapsed]
module.kube.aws_eks_cluster.this[0]: Creation complete after 10m52s [id=kube-course-01]
...
Apply complete!
...
```

The above process creates the Kubernetes client configuration in `./config`.
You can now list available nodes of the cluster using it:

In folder `/course/kube`:
```shell
kubectl --kubeconfig ./config get nodes
```

The expected result:
```
NAME                                           STATUS   ROLES    AGE   VERSION
ip-10-0-2-50.ap-southeast-2.compute.internal   Ready    <none>   11m   v1.19.6-eks-49a6c0
```

## Lab: Configure "kubectl", verify it can list all pods in the EKS cluster

// TODO MKN: elaborate more on contents of file "./config"

In folder `/course/kube`:
```shell
kubectl --kubeconfig ./config get pods --all-namespaces
```

// TODO MKN: document that the Course container should be restarted to place the config for 
   the newly created EKS cluster into the home directory on start. 
