#!/usr/bin/bash
MAIN_PATH="$HOME/Projetos/java-helper"
source "$MAIN_PATH/core/envvars.sh"

function dumpVars(){
	unset CLASSPATH
	unset MAIN_CLASS
	unset PROJECT_NAME
	unset SOURCES_FOLDER
	unset CLASSES_FOLDER
	unset MAIN_PATH
}

function parseClasspath(){
	# $1 -> classpath file path
	if [ -z $1 ]
	then
		cp="$MAIN_PATH/classpaths/default.jcp"
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
	arr=($1)
	dt=$(printf "%s:" "${arr[@]}")
	echo -e ${dt::-1}
}


function setHelperData(){
	# $1 the path to the classpath file
	# $2 the path to the run file
	# $3 the path to the compile file

	SOURCES_FOLDER=$(dialog --stdout \
			--clear \
			--title "Choose the sources folder of the project" \
			--fselect ./ 8 40)
		
	CLASSES_FOLDER=$(dialog --stdout \
			--clear \
			--title "Choose the output folder, where the compiled files will stay" \
			--fselect ./ 8 40)

	MENU_SELECTION=$(dialog --stdout \
			--clear \
			--title "About the classpath of the Java project" \
			--menu "Choose the classpath to use" \
			20 50 4 \
			1 "Load default ($MAIN_PATH/default.jcp)" \
			2 "Load Other preseted file (.jcp)" \
			3 "Select the paths to the classpath" \
			4 "Write the own classpath (dumped)" )

	# echo $MENU_SELECTION
	CLASSPATH=""

	if [ $MENU_SELECTION -eq 1 ] 
	then
		local cp=$(parseClasspath )
		CLASSPATH=$(dumpClasspathFile "${cp[@]}")
	else
		if [ $MENU_SELECTION -eq 2 ] 
		then
			local PATTERN_SELECTED=$(dialog --stdout --clear \
					--title "Select the .jcp file from the patterns" \
					--fselect "$MAIN_PATH/classpaths" 8 40 )
			local cp=$(parseClasspath $PATTERN_SELECTED)
			CLASSPATH=$(dumpClasspathFile "${cp[@]}")
		else 
			if [ $MENU_SELECTION -eq 3 ]
			then
				con=0
				declare -a files_cp=()
				while [ $con = 0 ] 
				do
					PATH_TO_ADD=$(dialog --stdout --clear \
						--title "Select the folder path" \
						--fselect ./ 8 40 )
					files_cp+=($PATH_TO_ADD)
					dialog --clear \
						--yesno "Add a new folder to classpath?" 8 40
					con=$?
				done
				CLASSPATH=$(dumpClasspathFile "${files_cp[@]}")
			else 
				CLASSPATH=$(dialog --stdout --clear \
					--title "Classpath" \
					--inputbox "Type your own classpath\nLike path:other_path" 8 40)
			fi

		fi
	fi
	#echo $CLASSPATH

	MAIN_CLASS=$(dialog --stdout --clear \
		--title "Select the project main class" \
		--fselect "$SOURCES_FOLDER/" 8 40)
	#IFS="/" readarray arr_pwd "$(pwd)"
	PROJECT_NAME=$(dialog --stdout --clear \
		--title "Type the project name" \
		--inputbox "Type the project name" 8 40 "${PWD##*/}")
	# echo $PROJECT_NAME

	# generates the .helper file
	function gen(){
		echo "# Data about the project, and used to compile/run" | tee ./.helper >> /dev/null 
		echo "MAIN_CLASS=\"$MAIN_CLASS\"" | tee -a ./.helper >> /dev/null 
		echo "CLASSPATH=\"$CLASSPATH\"" | tee -a ./.helper >> /dev/null
		echo "PROJECT_NAME=\"$PROJECT_NAME\"" | tee -a ./.helper >> /dev/null
		echo "SOURCES_FOLDER=\"$SOURCES_FOLDER\"" | tee -a ./.helper >> /dev/null
		echo "CLASSES_FOLDER=\"$CLASSES_FOLDER\"" | tee -a ./.helper >> /dev/null
	}

	(gen &)
	dialog --clear --msgbox "Helper configurations done!" 8 40

}

function genCompileScript(){
	if [ ! -f "./.helper" ]; then echo "Can't load file .helper, your project have to be created before"; exit -1 ;fi

	source .helper
	local comp_path=$(dialog --stdout --clear \
		--title "Compilation; Select the path to the compilator script" \
		--fselect ./ 8 40 )
	local comp_path+="/compile.sh"
	echo "#!/usr/bin/bash" | tee $comp_path >> /dev/null
	echo "javac -cp \"$CLASSPATH\" -d $CLASSES_FOLDER \$1" | tee -a $comp_path >> /dev/null
	chmod 777 compile.sh
	dialog --clear --infobox "Hold up..." 8 40
	sleep 5
	dialog --clear --msgbox "Compilation Script done!" 8 40
	dumpVars
}

function genRunScript(){
	if [ ! -f "./.helper" ]; then echo "Can't load file helper, your project have to be created before"; exit -1; fi
	source .helper
	local run_path=$(dialog --stdout --clear \
		--title "Runing; Select the path to the run script" \
		--fselect . 8 40 )
	local run_path+="/run.sh"
	if [ ! -f $run_path ]; then touch $run_path; fi
	chmod 777 $run_path
	echo "#!/usr/bin/bash" | tee $run_path >> /dev/null
	echo "java -cp \"$CLASSPATH\" $SOURCES_FOLDER/$MAIN_CLASS" | tee -a $run_path >> /dev/null
	#dialog --clear --msgbox "Runtime Script done!" 8 40
	#dumpVars
}

function compile(){
	if [ ! -f "./.helper" ]; then echo "Can't load file helper, your project have to be created before!"; exit -1; fi
	source .helper
	javac -cp "$CLASSPATH" -d "$CLASSES_FOLDER" $1
	echo "Compiled"
	dumpVars
}

function run(){
	if [ ! -f "./.helper" ]; then echo "Can't load file helper, your project have to be created before!"; exit -1; fi
	source .helper
	java -cp "\"$CLASSPATH\"" "$MAIN_CLASS"
	dumpVars
}



function getProjectData(){
	if [ ! -f "./.helper" ]; then echo "Can't load file helper, your project have to be created before!"; exit -1; fi
	source .helper
	# TODO
}




