# Lab: Verify Terraform can be used with the configured AWS account

// TODO MKN: elaborate on: "Basic Test Using AMI Lookup"

## terraform init

In folder `/course/misc/initial_terraform_aws_test`:
```shell
terraform init
```

The expected output:
```
Terraform has been successfully initialized!
```

It should create the following files and folders in `misc/initial_terraform_aws_test/`
```
.terraform
.terraform.lock.hcl
```

## terraform plan & apply

### plan 

```shell
terraform plan
```

The expected result: a couple of pages with the following in the end:
```
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + url = (known after apply)
```

### apply

```shell
terraform apply -auto-approve
```

The expected result:
```
aws_security_group.web: Creating...
aws_security_group.web: Creation complete after 2s [id=sg-092ec5c673072505f]
aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Still creating... [20s elapsed]
aws_instance.web: Still creating... [30s elapsed]
aws_instance.web: Creation complete after 32s [id=i-05eac6af519bd4cc1]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

url = "http://13.210.15.226"
```

After like couple of minutes (after the test EC2 instance fully initializes), 
you can open the url from your outputs in your browser. 
Above, it looks like `url = "http://13.210.15.226"`

You should see:
> Terraform and AWS

## terraform destroy

```shell
terraform destroy -auto-approve
```

The expected result:
```
aws_security_group.web: Refreshing state... [id=sg-092ec5c673072505f]
aws_instance.web: Refreshing state... [id=i-05eac6af519bd4cc1]
aws_instance.web: Destroying... [id=i-05eac6af519bd4cc1]
aws_instance.web: Still destroying... [id=i-05eac6af519bd4cc1, 10s elapsed]
aws_instance.web: Still destroying... [id=i-05eac6af519bd4cc1, 20s elapsed]
aws_instance.web: Still destroying... [id=i-05eac6af519bd4cc1, 30s elapsed]
aws_instance.web: Still destroying... [id=i-05eac6af519bd4cc1, 40s elapsed]
aws_instance.web: Still destroying... [id=i-05eac6af519bd4cc1, 50s elapsed]
aws_instance.web: Still destroying... [id=i-05eac6af519bd4cc1, 1m0s elapsed]
aws_instance.web: Destruction complete after 1m1s
aws_security_group.web: Destroying... [id=sg-092ec5c673072505f]
aws_security_group.web: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```
