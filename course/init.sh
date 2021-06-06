#!/bin/sh

set -e

cat << EOF >> ~/.bashrc

# kubectl is a popular cli tool, so we register a shorter alias for it
alias k=kubectl

# We want files created using the container to be conveniently editable also in the filesystem of the host OS
umask 0000

# The "TF_VAR..." assignments below make corresponding values visible to Terraform
export TF_VAR_region="${AWS_DEFAULT_REGION}"

# Note: keeping the below value empty is Ok (no notifications get sent in this case).
export TF_VAR_node_termination_handler_webhook_url="${NODE_TERMINATION_HANDLER_WEBHOOK_URL}"

EOF

if [ -f '/course/kube/config' ]
then
  mkdir -p ~/.kube
  cp /course/kube/config ~/.kube/config
  chmod o-r,g-r ~/.kube/config
fi

if [ -f '/course/misc/functions.sh' ]
then
  cat '/course/misc/functions.sh' >> ~/.bashrc
fi
