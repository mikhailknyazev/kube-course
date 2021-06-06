#!/bin/sh

set -e

#// TODO MKN: add more comments here

cd "$( dirname "$0" )"
pwd

cd misc/initial_terraform_aws_test
pwd
terraform destroy -auto-approve
