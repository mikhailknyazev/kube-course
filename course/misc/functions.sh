
_podDetails() {
  echo $(kubectl get pod -A -o json | jq -r "[.items[] | select (.metadata.name | startswith(\"${1}\")) | .metadata | {name, namespace, creationTimestamp}] | sort_by(.creationTimestamp | fromdate) | last(.[]) | \"\(.name) \(.namespace)\"")
}

cdkube() {
  cd '/course/kube/'
}

cdrel() {
  cd '/course/reliability/'
}
alias cdreliability=cdrel

cdconf() {
  cd '/course/config/'
}
alias cdconfig=cdconf

deploy() {
  cd '/course/workloads/' && pwd && ./helm-basic.sh deploy && cd -
}

destroy() {
  cd '/course/workloads/' && pwd && ./helm-basic.sh destroy && cd -
}

cleantests() {
  /course/reliability/clean-tests.sh
}
alias ct=cleantests

descrpo() {

  if [[ $# -lt 1 ]]
  then
    echo "Usage: descrpo <pod_name_pref>"
    echo "  <pod_name_pref>: prefix of a pod name to describe"
    return 1
  fi

  local pd=$(_podDetails ${1})
  local pod_name pod_namespace
  read pod_name pod_namespace <<< "${pd}"

  if [ "$pod_name" = "null" ]
  then
    echo "Pod with prefix '${1}' not found."
    return 2
  fi

  (set -x; kubectl describe pod "${pod_name}" -n "${pod_namespace}")

}

poyaml() {

  if [[ $# -lt 1 ]]
  then
    echo "Usage: poyaml <pod_name_pref>"
    echo "  <pod_name_pref>: prefix of a pod name to get YAML definition"
    return 1
  fi

  local pd=$(_podDetails ${1})
  local pod_name pod_namespace
  read pod_name pod_namespace <<< "${pd}"

  if [ "$pod_name" = "null" ]
  then
    echo "Pod with prefix '${1}' not found."
    return 2
  fi

  local filename="${pod_name}.yaml"
  (set -x; kubectl get pod "${pod_name}" -n "${pod_namespace}" -o yaml > "${filename}")
  echo "Saved YAML into ${filename}"

}

pojson() {

  if [[ $# -lt 1 ]]
  then
    echo "Usage: pojson <pod_name_pref> [-k]"
    echo "  <pod_name_pref>: prefix of a pod name to get JSON definition"
    echo "  -k : keep the 'managedFields'"
    return 1
  fi

  local pd=$(_podDetails ${1})
  local pod_name pod_namespace
  read pod_name pod_namespace <<< "${pd}"

  if [ "$pod_name" = "null" ]
  then
    echo "Pod with prefix '${1}' not found."
    return 2
  fi

  local last_param="${@: -1}"
  local json=$(set -x; kubectl get pod "${pod_name}" -n "${pod_namespace}" -o json)
  if [ "${last_param}" = "-k" ]
  then
    local filename="${pod_name}.json"
    echo $json | jq -M '.' > "${filename}"
    echo "Saved JSON into ${filename}"
  else
    local filename="${pod_name}_noManagedFields.json"
    echo $json | jq -M 'del(.metadata.managedFields)' > "${filename}"
    echo "Saved JSON less 'managedFields' into ${filename}"
  fi

}

pods() {
  local args=()

  if [ -n "${1}" ]
  then
    args+=( -n "${1}" )
  else
    args+=( -A )
  fi

  (set -x; kubectl get pod "${args[@]}")
}

logs() {

  if [[ $# -lt 1 ]]
  then
    echo "Usage: logs <pod_name_pref> [<container_name>] [-p|-f]"
    echo "  <pod_name_pref>: prefix of a pod name to get logs (single container)"
    echo "  <container_name>: request logs only for the specified container"
    echo "  -p : request the kubectl '--previous' logs"
    echo "  -f : request the kubectl '--follow' logs (along with the standard output to file)"
    return 1
  fi

  local pd=$(_podDetails ${1})
  local pod_name pod_namespace
  read pod_name pod_namespace <<< "${pd}"

  if [ "$pod_name" = "null" ]
  then
    echo "Pod with prefix '${1}' not found."
    return 2
  fi

  local log_filename=''

  local args=()

  local last_param="${@: -1}"

  if [ "${last_param}" = "-p" ]
  then
    args+=( --previous )
  fi

  if [ -n "${2}" ] && [ "${2}" != "-p" ] && [ "${2}" != "-f" ]
  then
    args+=( --container "${2}" )
    log_filename="${pod_name}__${2}.log"
  else
    log_filename="${pod_name}.log"
  fi

  if [ "${last_param}" = "-f" ]
  then
    (set -x; kubectl logs "${pod_name}" -n "${pod_namespace}" "${args[@]}" --follow | tee -a "${log_filename}")
  else
    (set -x; kubectl logs "${pod_name}" -n "${pod_namespace}" "${args[@]}" > "${log_filename}")
    echo "Saved log into ${log_filename}"
  fi

}

descrnodes() {
  kubectl describe nodes
}

nodes() {
  kubectl get nodes
}

ops() {

  local asgs=$(aws autoscaling describe-auto-scaling-groups \
              --query 'AutoScalingGroups[? Tags[? (Key==`kubernetes.io/cluster/kube`) && Value==`owned`]].{azs:AvailabilityZones,tname:Tags[?Key==`Name`]|[0].Value,desired:DesiredCapacity,instances:Instances[*].{instanceId:InstanceId,lifecycleState:LifecycleState}}')

  local instanceIds=$(echo $asgs | jq -r -M '.[] | .instances | .[] | .instanceId' | tr '\n' ' ')

  local instances=$(aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].{instanceId:InstanceId,spot:InstanceLifecycle,kname:PrivateDnsName,az:Placement.AvailabilityZone,state:State.Name,tname:Tags[?Key==`Name`]|[0].Value}' \
    --instance-ids ${instanceIds} \
    --output json | jq -M 'flatten')

  local nodes=$(kubectl get node -o json | jq -M '[.items[] | {conditions: .status.conditions, taints: .spec.taints, kname: .metadata.name, role: .metadata.labels.role, lifecycle: .metadata.labels["node.kubernetes.io/lifecycle"] }]')

  # Black        0;30     Dark Gray     1;30
  # Red          0;31     Light Red     1;31
  # Green        0;32     Light Green   1;32
  # Brown/Orange 0;33     Yellow        1;33
  # Blue         0;34     Light Blue    1;34
  # Purple       0;35     Light Purple  1;35
  # Cyan         0;36     Light Cyan    1;36
  # Light Gray   0;37     White         1;37

  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local BLUE='\033[0;34m'
  local YELLOW='\033[1;33m'
  local LBLUE='\033[1;34m'
  local NC='\033[0m'

  local NRF='No resources found'

  # // TODO minor MKN: consider special reporting of the Failed and Unknown ones (in addition to Pending)
  local pending_pods=$(kubectl get pod -A --field-selector status.phase=Pending 2>&1)
  if [ "${pending_pods}" != "${NRF}" ]
  then
    echo
    echo -e "${RED}******************************************************************************************${NC}"
    echo "${pending_pods}"
  fi

  for asg in $(echo $asgs | jq -c -M '. | sort_by(.tname) | .[]')
  do

    echo

    local NUM_LABELS=("ZERO" "ONE" "TWO" "THREE" "FOUR" "FIVE" "SIX" "SEVEN" "EIGHT" "NINE" "TEN" "ELEVEN" "TWELVE")
    local desired=$(echo $asg | jq -r -M ".desired ")
    if [ "${desired}" -le 12 ]
    then
      desired=${NUM_LABELS["${desired}"]}
    fi

    local asg_header=$(echo $asg | jq -r -M "\"\(.tname | ascii_upcase): desired "${desired}" instances in \(.azs | sort | join (\", \") )\"")

    echo -e "${LBLUE}*** ${asg_header}${NC}"

    for i in $(echo $asg | jq -c -M '.instances |  sort_by(.instanceId) | .[]')
    do
      local s1=$(echo $i | jq -r -M '"EC2 \(.instanceId) \(.lifecycleState)"')
      local instanceId=$(echo $i | jq -r -M '.instanceId')

      local s2=$(echo $instances | jq -r -M ".[] | select(.instanceId == \"${instanceId}\") | \", \(.state) in \(.az)\" ")

      local spot=$(echo $instances | jq -r -M ".[] | select(.instanceId == \"${instanceId}\") | .spot ")
      if [ "${spot}" = 'null' ]
      then
        spot=''
      else
        spot=", ${spot}"
      fi

      echo
      local state=$(echo $instances | jq -r -M ".[] | select(.instanceId == \"${instanceId}\") | .state ")
      if [ "${state}" = 'running' ]
      then
        echo -e "${GREEN}${s1}${s2}${spot}${NC}"
      else
        echo -e "${RED}${s1}${s2}${spot}${NC}"
      fi

      local kname=$(echo $instances | jq -r -M ".[] | select(.instanceId == \"${instanceId}\") | .kname ")

      if [ "${kname}" = 'null' ]
      then
        echo -e "${RED}N/A for Kubernetes${NC}"
      else
        local role=$(echo $nodes | jq -r -M ".[] | select(.kname == \"${kname}\") | (.role | ascii_upcase)")
        if [ -n "$role" ]
        then
          role="${role} "
        fi

        local conditions=$(echo $nodes | jq -M ".[] | select(.kname == \"${kname}\") | .conditions")
        local isReady=$(echo $conditions | jq -r -M '.[] | select (.type == "Ready") | .status')

        if [ "${isReady}" = 'True' ]
        then
          echo -e "${GREEN}${role}Ready ${kname}${NC}"
        else
          echo -e "${RED}${role}Not Ready ${kname}${NC}"
        fi

        local taints=$(echo $nodes | jq -c -M ".[] | select(.kname == \"${kname}\") | .taints")
        if [ "${taints}" != 'null' ] && [ -n "${taints}" ]
        then
          echo -e "${GREEN}TAINTS: ${taints}${NC}"
        fi

        kubectl get pod -A -l k8s-app!=aws-node,k8s-app!=kube-proxy --field-selector spec.nodeName=${kname}
      fi

    done

  done

  echo

}

opsview() {
  export -f ops
  watch -c -t -x bash -c ops
}

jenkins() {
  echo 'Jenkins Dashboard...'
  local jenkins_password=$(kubectl exec --namespace jenkins svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password)
  local jenkins_hostname=$(kubectl get ingress jenkins -n jenkins -o json | jq -r '.status.loadBalancer.ingress[0].hostname')
  echo "  admin"
  echo "  ${jenkins_password}"
  echo "  http://${jenkins_hostname}/jenkins/"
}

argoui() {
  echo 'Argo Dashboard...'
  local argo_hostname=$(kubectl get ingress argo-server -n litmus -o json | jq -r '.status.loadBalancer.ingress[0].hostname')
  echo "  http://${argo_hostname}/workflows/litmus"
}
