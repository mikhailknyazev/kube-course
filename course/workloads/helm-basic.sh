#!/bin/bash

set -e
cd $(dirname $0)

if [[ $# -lt 1 ]]
then
  echo "Usage: helm-basic.sh <action>"
  echo "  <action>: must be 'plan', 'plan-destroy', 'deploy', 'destroy', 'test' or 'debug'"
  exit 1
fi

action_param="$1"
aws_account_id=$(terraform output -state=../kube/terraform.tfstate -raw aws_account_id)
cluster_name=$(terraform output -state=../kube/terraform.tfstate -raw cluster_name)
helm_test_service_account_name=$(terraform output -state=../kube/terraform.tfstate -raw helm_test_service_account_name)

source ./lib/scripts/helm-utils.sh

doHelm -n basic -c apps -v 1.0.0 -a "${action_param}" -w "${aws_account_id}" -s "${cluster_name}" -m "${helm_test_service_account_name}"
