#!/bin/bash

region=us-east-1
#$processor="2-create-ami.sh"
command="./hello.sh"
#command="./2-create-ami.sh"
processor=$(eval $command)

argumentArray=("$@")
argumentCount=("$#@")

if [ "$#" -eq "0" ]; then
	printf "\n\nPlease provide at least ONE file to process.\n\n"
	printf "Format is \"%s file1.txt file2.txt ... fileX.txt\".\n\n" $0
else
	printf "%s files to process. \n" "$#"

fi

COUNT=1


for LISTFILE in "${argumentArray[@]}"; do
	INCR=$((COUNT++))
	
	IFS=$'\r\n' command eval  'listFile=($(cat $LISTFILE))'
	
	printf "Processing file %s\n\n" "$LISTFILE"
	
	for TARGET in "${listFile[@]}"; do

		./2-create-ami.sh $TARGET
		
	done
done
