#!/usr/bin/bash
MAIN_PATH="$HOME/Projetos/java-helper"
source "$MAIN_PATH/core/envvars.sh"

function parseClasspath(){
	# $1 -> classpath file path
	if [ -z $1 ]
	then
		cp="$MAIN_PATH/default.jcp"
	else
		cp=$1
	fi
	IFS="\n" readarray paths < $cp

	choices=""
	spe=""
	counter=1
	for i in ${paths[@]}
	do
		choices+=" $i $counter ON"
		counter=$[counter+1]
	done

	choosen_paths=$( dialog --stdout  \
			--title "Choose the files from the selected classpath" \
			--clear           \
			--separate-output \
			--checklist "Choose the paths to use from file $cp" 0 0 $[n] \
			$choices)
	# echo ${choosen_paths[@]}
	echo ${choosen_paths[@]}
}
function dumpClasspathFile(){
	# echo "${arr[@]}" | tee -a /tmp/debug-shit.tx
	arr=($1)
	dt=$(printf "%s:" "${arr[@]}")
	echo -e ${dt::-1}
}
