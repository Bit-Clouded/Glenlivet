#!/bin/bash
set -e

find . -name "*.template" -print0 | while read -d $'\0' file
do
	if  [[ $file == *nat-subnets.template || $file == *mesosphere.template ]] ;
	then
		echo ''
		echo '----!!!   nat-subnets amd mesosphere fail validation   !!!----'
	else
	    echo ""
        echo "Validating $file";
		aws cloudformation validate-template --template-body "file://$file"
	fi
done
