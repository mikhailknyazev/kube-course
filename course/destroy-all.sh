#!/bin/bash

set -e

echo 'Destroying infrastructure:'
echo '  /course/misc/initial_terraform_aws_test'

readonly expectedSteps=1
actualSteps=0

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

destroyInfra() {
  cd "$( dirname "$0" )"
  echo
  echo -e "${BLUE}*** PLANNED STEPS COUNT: ${expectedSteps} ********${NC}"
  echo -e "${BLUE}*** Performing step 1/1... ********${NC}"
  echo
  cd misc/initial_terraform_aws_test
  pwd

  terraform destroy -auto-approve

  actualSteps=$((actualSteps + 1))

  echo
  echo -e "${BLUE}*** Step 1/1 complete *************${NC}"
}

checkDestroyComplete() {
  echo
  echo -e "${BLUE}*** COMPLETED ${actualSteps} / ${expectedSteps} STEPS *********${NC}"
  if [ "${actualSteps}" -eq "${expectedSteps}" ]
  then
    echo -e "${GREEN}Done${NC}"
  else
    echo
    echo -e "${RED}Destroy has not completed completely. Please review the details above.${NC}"
    echo -e "${RED}In emergency, use the created 'kube-course' AWS Resource Group to manually destroy the remaining infrastructure.${NC}"
    echo -e "${RED}WARNING: the manual removal will likely make the terraform.tfstate files unusable, so consider their removal as well.${NC}"
  fi
}

read -p "Continue (y/n)? " choice
case "$choice" in
  y|Y )
    trap checkDestroyComplete EXIT
    destroyInfra
    ;;
  n|N ) echo "Exiting with no action..." ;;
  * ) echo 'Expected "y" or "n". Exiting with no action...' ;;
esac

