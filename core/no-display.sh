#!/usr/bin/bash

function progressbar(){
	for i in $(seq 0 10 100); do
		points=""
		for p in $(seq 0 $i); do points+="."; done
		printf "\r[$1]$points[$i%%]"
		sleep 1.2
	done
	printf "\n"
}

function setHelper(){
	content="#!/usr/bin/bash\n"
	# echo $[${#@}] | tee -a /tmp/debug-shit.txt
	#exit 0
	if [ "$[${#@}]" -ge 10 ] 
	then
		local OPTIND
		while getopts "c:s:o:p:m:h" opt "$@"; do
			case "$opt" in
				c)
					content+="CLASSPATH=\"$OPTARG\"\n"
					;;
				s)
					content+="SOURCES_FOLDER=\"$OPTARG\"\n"
					;;
				o)
					content+="CLASSES_FOLDER=\"$OPTARG\"\n"
					;;
				p)
					content+="PROJECT_NAME=\"$OPTARG\"\n"
					;;
				m)
					content+="MAIN_CLASS=\"$OPTARG\"\n"
					;;
				h)
					# TODO:> Create the help text
					echo "Help activated"
					return 1
					;; 

				\?)
					echo "ERROR"
					return -1
					;;
			esac
		done
		shift $((OPTIND -1))
	else
		echo -ne "Welcome to the low level project setting assistent\nPlease entry the Project Name: "; read projname
		echo -ne "Now what's the Project Sources folder?: "; read srcf
		echo -ne "And what file is the main class?: "; read mc
		echo -ne "And what's the Project classes output folder?: "; read outf
		echo -ne "Now insert the classpath text, I recommend you to insert in it the classes output folder \"$outf\": "; read classpath
		content+="CLASSPATH=\"$classpath\"\n"
		content+="PROJECT_NAME=\"$projname\"\n"
		content+="SOURCES_FOLDER=\"$srcf\"\n"
		content+="CLASSES_FOLDER=\"$outf\"\n"
		content+="MAIN_CLASS=\"$mc\"\n"

	fi
	progressbar "Working on it"
	echo -e $content | tee .helper >> /dev/null
	echo "Project setted up successfully UwU"

}


