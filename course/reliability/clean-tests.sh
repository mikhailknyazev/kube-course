#!/bin/sh

set -e

kubectl delete chaosengine --all -n litmus
kubectl delete chaosresult --all -n litmus
kubectl delete workflows --all -n litmus
