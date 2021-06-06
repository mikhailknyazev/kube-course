#!/bin/bash

lower() {
  echo "${1}" | tr '[:upper:]' '[:lower:]'
}

usage() {
  echo "Usage:"
  echo " -n Microservice name."
  echo " -c Target namespace"
  echo " -s Name of the target EKS cluster"
  echo " -v App version used. Microservice docker image version to be deployed. For example, 0.2"
  echo " -r [Optional] Chart version used. It is supposed to change whenever the templates/dependencies or app version changes"
  echo "               Defaults to: 1.0.(date +%Y%m%d%H%M%S)"
  echo " -a Action to take. Accepted values: plan, deploy, plan-destroy, destroy, test, debug"
  echo " -w AWS Account Number"
  echo " -t Timeout duration for plan/deploy. E.g. 15m0s, default 5m0s"
  echo " -m [Optional] Non-default Service Account name for the Helm Test pods"
}

doHelm() {

  local svc_name=""
  local namespace=""
  local cluster_name=""
  local app_version=""
  local chart_version="1.0.$(date "+%Y%m%d%H%M%S")"
  local action=""
  local timeout_duration="5m0s"
  local aws_account=""
  local helm_test_service_account_name="default"

  while getopts ":n:c:s:v:r:a:t:w:m:" opt
  do
    case ${opt} in
      n ) svc_name=$(lower "${OPTARG}") ;;
      c ) namespace=$(lower "${OPTARG}") ;;
      s ) cluster_name="${OPTARG}" ;;
      v ) app_version="${OPTARG}" ;;
      r ) chart_version="${OPTARG}" ;;
      a ) action=$(lower "${OPTARG}") ;;
      t ) timeout_duration="${OPTARG}" ;;
      w ) aws_account="${OPTARG}" ;;
      m ) helm_test_service_account_name="${OPTARG}" ;;
      \? )
        echo "Invalid option: ${OPTARG}" 1>&2
        usage
        exit 2
        ;;
      : )
        echo "Invalid option: ${OPTARG} requires an argument" 1>&2
        usage
        exit 2
        ;;
    esac
  done

  echo "Performing '${action}' for name=${svc_name} namespace=${namespace} cluster_name=${cluster_name} app_version=${app_version} chart_version=${chart_version} aws_account=${aws_account} ..."

  # Validating the action

  if ! [[ "${action}" =~ ^(plan|plan-destroy|deploy|destroy|test|debug)$ ]]
  then
    echo "-a ${action}"
    echo "Action must be either of 'plan', 'plan-destroy', 'deploy', 'destroy', 'test' or 'debug'"
    exit 2
  fi

  echo 'Updating the Chart versions...'
  local chart_yaml_path="./${svc_name}/Chart.yaml"
  if [[ -f ${chart_yaml_path} ]]
  then
    chmod +w ${chart_yaml_path}
  fi
  cp "./${svc_name}/Chart.tpl.yaml" ${chart_yaml_path}
  sed -i "s/^version:.*$/version: \"${chart_version}\"/" "${svc_name}"/Chart.yaml
  sed -i "s/^appVersion:.*$/appVersion: \"${app_version}\"/" "${svc_name}"/Chart.yaml
  chmod -w ${chart_yaml_path}

  local args=( --namespace "${namespace}" )
  local post_deployment_test_args=()
  if [[ "${action}" =~ ^(plan|deploy|debug)$ ]]
  then

    echo 'Preparing the JSON Schema...'
    local schema_path="./${svc_name}/values.schema.json"
    if [[ -f ${schema_path} ]]
    then
      chmod +w ${schema_path}
    fi
    cp ./lib/schemas/values.schema.json ${schema_path}
    chmod -w ${schema_path}

    args+=( --timeout "${timeout_duration}" )
    post_deployment_test_args=("${args[@]}")

    args+=( --set "namespace=${namespace}" )
    args+=( --set "clusterName=${cluster_name}" )
    args+=( --set "awsAccount=${aws_account}" )
    args+=( --set "helmTest.serviceAccountName=${helm_test_service_account_name}" )
  fi

  echo "Executing '${action}'..."

  helm dependency update ./"${svc_name}"

  case "${action}" in
    plan)
      echo "PLANNING..."
      helm upgrade -f ./"${svc_name}"/values.yaml  "${svc_name}" ./"${svc_name}" \
        --install --dry-run --debug "${args[@]}"
      ;;
    deploy)
      echo "DEPLOYING..."

      #// TODO MKN: comment more on the "no-Deployment-before-Ingress fix" here
      if ! kubectl get deployment "${svc_name}" --namespace=${namespace} &> /dev/null
      then
        echo "Deployment of '${svc_name}' not found, so we first run 'helm upgrade' without Deployment..."

        # Note: we want to create the Deployment _after_ the Ingress,
        #       so we first do 'helm upgrade' excluding the Deployment definition.
        # See also: tip "create ingress or service before pod"
        #   here: https://kubernetes-sigs.github.io/aws-load-balancer-controller/guide/controller/pod_readiness_gate/
        helm upgrade -f ./"${svc_name}"/values.yaml "${svc_name}" ./"${svc_name}" \
          --install --set createDeployment=false --wait "${args[@]}"

        # Pause for 7 seconds to let ALB Controller prepare for the Deployment (be able to create Readiness Gates)
        echo "Waiting 7 seconds..."
        sleep 7

        echo "We are now running 'helm upgrade' with Deployment..."
      fi

      helm upgrade -f ./"${svc_name}"/values.yaml "${svc_name}" ./"${svc_name}" \
        --install --wait "${args[@]}"

      echo "POST-DEPLOYMENT TEST..."
      helm test "${svc_name}" --logs "${post_deployment_test_args[@]}"

      ;;
    debug)
      echo "DEBUG..."
      helm template --debug ./"${svc_name}"/values.yaml ./"${svc_name}" "${args[@]}"
      ;;
    plan-destroy)
      echo "PLAN-DESTROY..."
      helm uninstall "${svc_name}" "${args[@]}" --dry-run
      ;;
    destroy)
      echo "DESTROYING..."
      helm uninstall "${svc_name}" "${args[@]}"
      ;;
    test)
      echo "TEST..."
      helm test "${svc_name}" --logs "${args[@]}"
      ;;
    *)
      echo "UNEXPECTED: ${action}"
      exit 2
      ;;
  esac

}
