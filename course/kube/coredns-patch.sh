#!/bin/sh

set -e

# Note: "module.kube" creates this file:
kubeconfig='/course/kube/config'

echo "Waiting 20 seconds to let the EKS cluster settle down on creation..."
sleep 20

# Note: we are using the value of "local.system_ec2_logical_role_name" here: system-ec2
#       (we are not using it as a variable for readability of this script)

# Ensure the CoreDNS patched with the special toleration and preferred nodeAffinity
if ! kubectl --kubeconfig "${kubeconfig}" get deployment -n kube-system coredns -o=jsonpath='{.spec.template.spec.tolerations}' | grep system-ec2 > /dev/null
then
  echo "Patching the CoreDNS with the special toleration and preferred nodeAffinity..."
  kubectl --kubeconfig "${kubeconfig}" patch deployment -n kube-system coredns --type=json -p '[{"op":"add","path":"/spec/template/spec/tolerations/0","value": {"key": "system-ec2", "operator": "Equal", "value": "true", "effect": "NoExecute"}}, {"op":"add","path":"/spec/template/spec/affinity/nodeAffinity/preferredDuringSchedulingIgnoredDuringExecution","value": [{"weight": 10,"preference": {"matchExpressions": [{"key": "node.kubernetes.io/lifecycle","operator": "In","values": ["normal"]}]}}] }]'
  echo "Waiting 20 seconds to let CoreDNS restart..."
  sleep 20
  echo "CoreDNS should have been patched now"
else
  echo "CoreDNS already patched"
fi


