
# Configuring Kubernetes for Reliability with LitmusChaos

This repository contains main resources for Udemy course "Configuring Kubernetes for Reliability with LitmusChaos"

# Initialization

Cd into this directory.

Update the existing `env.txt` file:
```
AWS_ACCESS_KEY_ID=<your_access_key>
AWS_SECRET_ACCESS_KEY=<your_secret_access_key>
AWS_DEFAULT_REGION=<your_region>
AWS_DEFAULT_OUTPUT=json
```
so you have something like:
```
AWS_ACCESS_KEY_ID=IOPASSK2XQ3SFQ3Z7ULK
AWS_SECRET_ACCESS_KEY=/nOZasdTbgr9ioYbqasCcJu3V+22oiqlfVgtauqw
AWS_DEFAULT_REGION=ap-southeast-2
AWS_DEFAULT_OUTPUT=json
```

Run from the Terminal:
```shell
./run.sh
```

## Once you see the command prompt at the `michaelkubecourse/tools` container

### Check AWS access 

Check AWS is accessible and defaults to the expected region:
```shell
aws ec2 describe-availability-zones --query 'AvailabilityZones[0].[RegionName]'
```

The expected result:
```json
[
    "ap-southeast-2"
]
```

### Lab: Verify Terraform can be used with the configured AWS account

```shell
cd /course/misc/initial_terraform_aws_test/
```
After that, follow instructions in `/course/misc/initial_terraform_aws_test/README.md`
