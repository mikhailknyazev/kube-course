#!/bin/sh

set -e

curl https://hub.litmuschaos.io/api/chaos/1.13.5?file=charts/kube-aws/experiments.yaml | \
  sed "s/imagePullPolicy: Always/imagePullPolicy: IfNotPresent/" > \
  /course/reliability/helm/charts/kube-course-litmus-experiments/experiments/aws/litmus-aws-experiments.yaml

curl https://hub.litmuschaos.io/api/chaos/1.13.5?file=charts/generic/experiments.yaml | \
  sed "s/imagePullPolicy: Always/imagePullPolicy: IfNotPresent/" > \
  /course/reliability/helm/charts/kube-course-litmus-experiments/experiments/generic/litmus-generic-experiments.yaml

exit 0
