#!/bin/bash


# Test if the supplied IP is valid
#
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}



# assign the IP address
#
ADDR=$1

if [ -z "$ADDR" ]; then
	printf "Enter the IP address:  "
	read ADDR
	printf "IP ADDRESS requested: %s\n\n" $ADDR
else
	printf "IP ADDRESS supplied: %s\n\n" $ADDR
fi 

if valid_ip $ADDR; then
	ssh-keyscan $ADDR >> ~/.ssh/known_hosts
	printf "Copying admin setup script to %s" $ADDR
	sshpass -p 'nunesp2016' scp btr-admin-setup.sh  pedro.nunes@$ADDR:~/
	printf "\nDONE.\n\n"

	# This has problems when looping
	printf "Running remote admin user setup\n\n"
	sshpass -p 'nunesp2016' ssh  pedro.nunes@$ADDR -tt  'sudo ~/btr-admin-setup.sh' < /dev/null
	printf "\nDONE.\n\n"


else
	printf "%s is not a valid IP address.  STOPPING\n\n" $ADDR
fi



