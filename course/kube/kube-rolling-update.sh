#!/bin/sh

set -e

export K8S_AUTOSCALER_ENABLED=1
export K8S_AUTOSCALER_NAMESPACE="kube-system"
export K8S_AUTOSCALER_DEPLOYMENT="cluster-autoscaler"
export K8S_AUTOSCALER_REPLICAS=1

#
# "EKS Rolling Update" is an utility for updating the launch configuration of worker nodes in an EKS cluster.
# See also: https://github.com/hellofresh/eks-rolling-update
#
eks_rolling_update.py --cluster_name kube
