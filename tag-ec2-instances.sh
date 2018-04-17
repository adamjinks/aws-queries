#!/bin/bash

REGION=us-west-2
PROFILE=aws-profile-name


INSTANCE_LIST=$(aws --region ${REGION} --profile ${PROFILE} ec2  describe-instances --output text --query 'Reservations[*].Instances[*].[InstanceId ]')

# for debugging
# echo "instance list is: ${INSTANCE_LIST}"

for I in ${INSTANCE_LIST}
  do 
		echo "Tagging instance ${I}."
		aws --region ${REGION} --profile ${PROFILE} ec2 create-tags --resources ${I} --tags Key=AutoStart,Value=True Key=AutoStop,Value=True #--dry-run
  done

