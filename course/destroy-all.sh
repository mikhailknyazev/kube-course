#!/bin/sh

set -e

#// TODO MKN: add more comments here (and make it specific to the Steps)

cd "$( dirname "$0" )"
pwd

cd workloads
pwd
if helm status -n apps basic
then
  ./helm-basic.sh destroy
fi

cd ../reliability
pwd
terraform destroy -auto-approve

cd ../config
pwd
terraform destroy -auto-approve

cd ../kube
pwd
terraform destroy -auto-approve

cd ../misc/initial_terraform_aws_test
pwd
terraform destroy -auto-approve
