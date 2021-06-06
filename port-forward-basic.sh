#!/bin/sh

set -e

echo 'The "basic" microservice for the course (keep this console/terminal open):'
echo
echo 'http://localhost:8080/hello'
echo 'http://localhost:8080/hello?myName=MichaelK'
echo
docker run --rm --env-file env.txt \
  -v ${PWD}/course:/course \
  -p 127.0.0.1:8080:8080/tcp \
  michaelkubecourse/tools \
  kubectl port-forward --address 0.0.0.0 -n apps svc/basic 8080:8080
