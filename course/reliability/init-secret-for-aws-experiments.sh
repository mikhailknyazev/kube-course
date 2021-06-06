#!/bin/sh

set -e

# See also: https://docs.litmuschaos.io/docs/ec2-terminate-by-tag/

if [ -z "${AWS_ACCESS_KEY_ID}" ]
then
  echo 'AWS_ACCESS_KEY_ID environment variable is undefined. Check you are passing it in your env.txt for the Course.'
  exit 2
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]
then
  echo 'AWS_SECRET_ACCESS_KEY environment variable is undefined. Check you are passing it in your env.txt for the Course.'
  exit 2
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cloud-secret
  namespace: litmus
type: Opaque
stringData:
  cloud_config.yml: |-
    [default]
    aws_access_key_id = ${AWS_ACCESS_KEY_ID}
    aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF
