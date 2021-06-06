#!/bin/sh

set -e

# See also: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
echo 'Kubernetes Dashboard for the course (keep this console/terminal open):'
echo
echo 'http://localhost:6443/#/workloads?namespace=litmus'
echo
echo '**** ENTER THIS TOKEN BELOW TO AUTHENTICATE *****'
docker run --rm --env-file env.txt \
  -v ${PWD}/course:/course \
  -p 127.0.0.1:6443:443/tcp \
  michaelkubecourse/tools \
  /bin/bash -c "kubectl get secret \$(kubectl get sa dashboard -n dashboard -o json | jq -r '.secrets[0].name') -n dashboard -o json  | jq -r '.data.token' | base64 -d && echo && echo '*************************************************' && echo && kubectl port-forward --address 0.0.0.0 -n dashboard svc/dashboard 443:443"
