#!/bin/bash

if [ $# -eq 0 ]
then
	echo -e "\033[31;1;1mERROR\033[0m"
	echo
	echo "Please provide a github URL:"
	echo -e "    Exemple for ssh \033[37;1;1mgit@github.com:openmsa\033[0m"
	echo -e "    Exemple fot https \033[37;1;1mhttps://github.com/openmsa\033[0m"
	echo
	echo "You can change your remote by doing:"
	echo -e "    \033[37;1;1m./do.sh git remote ...\033[0m"
	exit 1
fi
for repo in etsi-mano-alarm etsi-mano-auth etsi-mano-config etsi-mano-data-model etsi-mano-docker etsi-mano-em etsi-mano-event etsi-mano-fluxrest etsi-mano-front-controllers etsi-mano-grammar etsi-mano-model etsi-mano-monitoring etsi-mano-orchestration etsi-mano-package-parser etsi-mano-pkg etsi-mano-pom etsi-mano-repo etsi-mano-vim etsi-mano-java etsi-mano-data-model-small
do
	if [ ! -d $repo ]
	then
		git clone $1/$repo
	fi
done
