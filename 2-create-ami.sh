#!/bin/bash
#
# Backs up EC2 instance by creating AMI
#

timestamp() {
# function to generate a timestamp
# output format is YYYYMMDDhhmmss
# e.g. for May 11, 2017 at 5:34pm and 16secs
# output is: 20170511173416
  date +"%Y%m%d%H%M%S"
}

timeStamp=$(timestamp)

# Choose your region
# e.g. us-west-2
region=us-east-1

instanceID=$1

if [ -z "$instanceID" ]; then
	printf "Source EC2 Instance ID: "
	read instanceID
fi

#instanceName=$(aws --region $region ec2 describe-instances --instance-id $instanceID --output text --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value')
instanceName=$(aws --region $region --profile btr ec2 describe-instances --instance-id $instanceID --output text --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value')

if [ -z "$instanceName" ] ; then
	instanceName=${instanceID}
fi

# availability zone might be useful to have as a tag down the road
availZone=$(aws --region $region ec2 describe-instances --instance-id $instanceID --output text --query 'Reservations[].Instances[].Placement.AvailabilityZone')


# Extract the EC2 meta-info as backup
instDescFile="meta/$instanceID.json"
aws --region $region ec2 describe-instances --instance-id $instanceID > $instDescFile

amiName=$instanceName-pv-source-$timeStamp

#############################################
# creating the AMI and tagging it
printf "Starting AMI creation.  "
#amiID=$(aws --region $region ec2 create-image --instance-id $instanceID --name $amiName --no-reboot --output text)
amiID=$(aws --region $region ec2 create-image --instance-id $instanceID --name $amiName --no-reboot --output text --dry-run)
printf "Done.\n"

printf "Tagging AMI.  "
aws --region $region ec2 create-tags --resources $amiID --tags Key="Project",Value=PV-2-HVM Key="Source EC2",Value=$instanceID Key="Name",Value=$instanceName Key="AZ",Value=$availZone
printf "Done. \n"


#######################################################o#
# wait until AMI is available then tag snapshots

printf "Waiting for snapshots to become available:."

while state=$(aws --region $region --output text ec2 describe-images --image-ids $amiID --query "Images[*].{status:State}")
        test "$state" = "pending"
        do
          sleep 1s
          printf "."
        done

# after status is available it still takes a few seconds to show up
sleep 5s


# tag the snapshots

snapShot=$(aws --region $region --output text ec2 describe-images --image-ids $amiID --query "Images[*].{this:[BlockDeviceMappings[].Ebs.SnapshotId]}")

x=3
for snapID in ${snapShot[0]}; do

        if ! ((x % 2)); then
                printf "Tagging snapshot: %s.\n" $snapID
                aws --region $region ec2 create-tags --resources $snapID --tags Key="Project",Value=PV-2-HVM Key="Source EC2",Value=$instanceID Key="Name",Value=$instanceName Key="AZ",Value=$availZone
        fi
        ((x++))
done


###########################################################




aws --region $region ec2 describe-images --image-ids $amiID >> $instDescFile


printf "EC2 Description file: %s.\nAMI ID: %s.\nAMI Name: %s.\n" $instDescFile $amiID $amiName
