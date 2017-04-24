#!/bin/bash
#
# Describes an EC2 instance including all its accessories
# 20170413

timestamp() {
# function to generate a timestamp
# output format is YYYYMMDDhhmmss
# e.g. for May 11, 2017 at 5:34pm and 16secs
# output is: 20170511173416
  date +"%Y%m%d%H%M%S"
}

timeStamp=$(timestamp)


##############################################################
# Config section
# 

# Choose your region
# e.g. us-west-2
region=us-east-1

# Path where meta-data json output file is stored
filePath="meta"


###############################################################

instanceID=$1

if [ -z "$instanceID" ]; then
	printf "Source EC2 Instance ID: "
	read instanceID
fi

instanceName=$(aws --region $region ec2 describe-instances --instance-id $instanceID --output text --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value')

if [ -z "$instanceName" ] ; then
	instanceName=${instanceID}
fi

# availability zone might be useful to have as a tag down the road
availZone=$(aws --region $region ec2 describe-instances --instance-id $instanceID --output text --query 'Reservations[].Instances[].Placement.AvailabilityZone')


# Extract the EC2 meta-info
instDescFile="$filePath/$instanceID.json"
echo "output file is $instDescFile ".
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










