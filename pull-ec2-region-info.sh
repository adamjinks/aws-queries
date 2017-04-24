#!/bin/bash
#
# Describes all EC2 instances in a Region
# 20170413

timestamp() {
# function to generate a timestamp
# output format is YYYY-MM-DD hh:mm:ss
# e.g. for May 11, 2017 at 5:34pm and 16secs
# output is: 2017-05-11 17:34:16
  date +"%Y-%m-%d-%H:%M:%S"
}


##############################################################
# Config section
# 

# Choose your region
# e.g. us-west-2
region=us-east-1

# Path where meta-data json output file is stored
# make sure to add a / after the pathname
# for current dir use "./"
filePath="meta/"

if [ ! -d "$filePath" ]; then
    printf "Creating missing directory %s\n\n" $filePath
    mkdir -p $filePath
fi

###############################################################

instanceIdList=$(aws --region $region ec2 describe-instances --output text --query 'Reservations[].Instances[].InstanceId')

# start looping thru the instances
for instanceID in ${instanceIdList}; do

 printf "Querying intance: %s.\n" $instanceID
        

 #####################
 # Begin querying the instance
 # ##################

  # Extract the EC2 meta-info
  instDescFile="$filePath$instanceID.json"

  aws --region $region ec2 describe-instances --instance-id $instanceID > $instDescFile


  # Extract the volumes info

  volumeID=$(aws --region $region --output text ec2 describe-instances --instance-id $instanceID --query "Reservations[].Instances[].{this:[BlockDeviceMappings[].Ebs.VolumeId]}")

  x=3
  for volID in ${volumeID[0]}; do

          if ! ((x % 2)); then
                  printf "Querying volume: %s.\n" $volID
                  aws --region $region ec2 describe-volumes --volume-ids $volID >> $instDescFile
          fi
          ((x++))
  done

  # Extract the eni info

  interfaceID=$(aws --region $region --output text ec2 describe-instances --instance-id $instanceID --query "Reservations[].Instances[].{this:[NetworkInterfaces[].NetworkInterfaceId]}")

  x=3
  for eniID in ${interfaceID[0]}; do

          if ! ((x % 2)); then
                  printf "Querying ENI: %s.\n" $eniID
                  aws --region $region ec2 describe-network-interfaces --network-interface-ids $eniID >> $instDescFile
          fi
          ((x++))
  done

  timeStamp=$(timestamp)
  printf "Queried at: %s\n" $timeStamp >> $instDescFile
 #####################
 # End querying the instance
 #####################
done
