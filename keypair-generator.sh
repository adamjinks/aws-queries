#!/bin/bash
#
# This script checks for a keypair, either as argument or inline var.
# If the keypair does not exist this will create a new keypair
# and save the PEM file to a secure parameter store value with
# the name of the keypair.

# set keypair name here or supply as command line argument 
KEYPAIR_NAME='test-keypair'

printf "Keypair Utility\n"

if [[ ! -z "${AWS_DEFAULT_PROFILE}" ]]; then
  printf "Default profile is set to \"%s\"\n" ${AWS_DEFAULT_PROFILE}
fi

if [ ! -z ${1} ]; then
  KEYPAIR_NAME=${1}
fi

check_for_keypair () {
  # check if our keypair exists
  printf "Check if keypair \"%s\" exists\n" ${1}
  OUTPUT=$(aws ec2 describe-key-pairs --key-name ${1} 2>&1)
  RESULT=${?}
  # aws ec2 describe-key-pairs --key-name test-keypair

  if [ ${RESULT} -ne 0 ]; then
    printf "Keypair \"%s\" does not exist.\n" ${1}
    KEYPAIR_EXISTS=0
  else
    printf "Keypair %s exists.\n" ${1}
    KEYPAIR_EXISTS=1
  fi
  }

create_keypair () {
  # create the keypair
  printf "Creating keypair \"%s\".\n" ${1}
  KEYPAIR_VALUE=$(aws ec2 create-key-pair --key-name ${1} | jq '.KeyMaterial')
  # save the keypair value / pem file to secure parameter
  OUTPUT=$(aws ssm put-parameter --name ${KEYPAIR_NAME} --value "${KEYPAIR_VALUE}" --type SecureString --overwrite)
  }

#====================================
check_for_keypair ${KEYPAIR_NAME}

if [ ${KEYPAIR_EXISTS} -eq 0 ]; then
  create_keypair ${KEYPAIR_NAME}
fi

# this line is purely for testing / re-running
# aws ec2 delete-key-pair --key-name ${KEYPAIR_NAME}
