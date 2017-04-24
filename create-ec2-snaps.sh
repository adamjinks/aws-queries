#!/bin/bash

# crate snapshots 

timestamp() {
# function to generate a timestamp
# output format is YYYYMMDDhhmmss
# e.g. for May 11, 2017 at 5:34pm and 16secs
# output is: 20170511173416
  date +"%Y%m%d%H%M%S"
}

# set your region
region=us-east-1

stamp=$(timestamp)

instanceID=$1

if [ -z "$instanceID" ]; then
        printf "Source EC2 Instance ID: "
        read instanceID
fi

# get the instance's Name for tagging later
instanceName=$(aws --region $region ec2 describe-instances --instance-id $instanceID --output text --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value')

if [ -z "$instanceName" ] ; then
        instanceName=${instanceID}
fi


# availability zone might be useful to have as a tag down the road
availZone=$(aws --region $region ec2 describe-instances --instance-id $instanceID --output text --query 'Reservations[].Instances[].Placement.AvailabilityZone')


# enumerate the attached volumes

volumeInfo=$(aws --region $region ec2 describe-instances --instance-id $instanceID --output text --query "Reservations[].Instances[].{Volume:[BlockDeviceMappings[].Ebs.VolumeId]}")

x=3
for volID in ${volumeInfo[0]}; do

        if ! ((x % 2)); then
	
	##############################################
	# so far the code to wait for the snap to exit
	# the pending state has not been required
	#
	#while state=$(aws --region $region --output text ec2  describe-snapshots --snapshot-ids $volID --query "Snapshots[*].{status:State}")
        #test "$state" = "pending"
        #do
          #sleep 1s
          #printf "."
        #done
	##########################################


            printf "\nSnapping volume: %s.\n-----\n" $volID
	    snapID=$(aws --region $region --output text ec2 create-snapshot --volume-id $volID --description "Backup $stamp")
	    echo $snapID 
	    ###############################
	    #   cycle thru the snapID array
	    #   and add the relevant tags
	    for snapItem in ${snapID[0]}; 
	    do
	     if [[ $snapItem == "snap-"* ]]; then
       	     tagOutput=$(aws --region $region ec2 create-tags --resources $snapItem --tags Key="Project",Value=PV-2-HVM Key="Source EC2",Value=$instanceID Key="Name",Value=$instanceName Key="SnapTime",Value=$stamp Key="AZ",Value=$availZone )
	     fi
	    done 
        fi
        ((x++))
done

