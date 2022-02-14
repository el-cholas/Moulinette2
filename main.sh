#!/bin/bash

# GLOBAL VARS
languagesDir="languages/"
currentLanguage="en"
projectDir="project/"
tmp="NULL" # This is used because I cannot return variables in bash
errorFile="errors.txt"
currentDir=$(pwd)


main () {
	chooseLanguage
	chooseExercise
	if ! [ -d "$projectDir" ]; then
        projectDirEmpty
    fi
    echo " " > $errorFile
	$tmp $tmp
	# rm -rf $projectDir
}

projectDirEmpty () {
    echo -n "$(readJSON "pasteGitURL") "
    read gitURL
    if $(git clone $gitURL); then
        # This gets the name of the folder in the git then removes the .git
        gitFolderName=$(echo $gitURL | rev | cut -d '/' -f1 | rev | sed 's/.git//g')
        mv $gitFolderName $projectDir
    else
    	echo "$(readJSON "gitCloneFailed") "
    fi
}

readJSON () {
	# Usage is " $(readJSON "key") "
	local fieldName=$1

	# $2 is a very buggy variable to use, I don't use it

	# If $2 is an empty variable, set it as the default language
	if [ -z "$2" ]
	then
    	filename="$languagesDir$currentLanguage.json"
	else
		filename="$languagesDir$2.json"
	fi
	grep -o '"'$fieldName'": "[^"]*' $filename | grep -o '[^"]*$'
}

# MENUS AND SELECTION STUFF, THESE COMMANDS ARE ALL THE SAME
chooseLanguage () {
	# If I could I would make a function to list an array and make a selection so I can resuse this code super easily
	# But bash sucks ass a bit with storing variables and returning variable

	# Store all json files into an array
	local files=($(find $languagesDir -name "*.json" -type f -exec basename {} .json ";"))
	local fileIndex=1

	# Loop through language files and print them out
	for languageName in "${files[@]}"
	do
		echo $fileIndex $languageName
		fileIndex=$(($fileIndex + 1))
	done

	# Ask user for language selection
	echo -n "$(readJSON chooseLanguage) "
	read languageIndex

	# If language is valid, set the global language variable, if not, say its invalid
	if (( $((languageIndex)) <=  fileIndex - 1 && $((languageIndex)) >= 1 ));
	then
		# Set the language
		currentLanguage=${files[((languageIndex)) - 1]}
	else
		echo $(readJSON "invalidLangSelection")
		chooseLanguage
	fi
}

chooseExercise () {
	# If I could I would make a function to list an array and make a selection so I can resuse this code super easily
	# But bash sucks ass a bit with storing variables and returning variable

	# Store all json files into an array
	local files=($(find ".DS_Store/" -name "c-piscine*" -type d -exec basename {} ";"))
	local fileIndex=1

	# Loop through language files and print them out
	for languageName in "${files[@]}"
	do
		echo $fileIndex $languageName
		fileIndex=$(($fileIndex + 1))
	done

	# Ask user for language selection
	echo -n "$(readJSON chooseExercise) "
	read languageIndex

	# If language is valid, set the global language variable, if not, say its invalid
	if (( $((languageIndex)) <=  fileIndex - 1 && $((languageIndex)) >= 1 ));
	then
		# Set the language
		tmp=${files[((languageIndex)) - 1]}
	else
		echo $(readJSON "invalidLangSelection")
		chooseExercise
	fi
}

# Exercises
c-piscine-shell-00-mac () {
	local var=""
}

c-piscine-shell-01-mac () {
	local correctPath=".DS_Store/$1"
	local currentPath=${projectDir///}

	local script=""
	local exercise=""
	local commandDiff=""

	# ex01
	script="print_groups.sh"
	exercise="ex01"
	FT_USER=$(whoami)
	export FT_USER
	commandDiff=$(diff <(./$correctPath/$exercise/$script) <(./$currentPath/$exercise/$script))
	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex02
	script="find_sh.sh | cat -e"
	exercise="ex02"
	commandDiff=$(diff <(./$correctPath/$exercise/$script) <(./$currentPath/$exercise/$script))
	status=$?
	if [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex03
	script="/count_files.sh | cat -e"
	exercise="ex03"
	commandDiff=$(diff <(./$correctPath/$exercise/$script) <(./$currentPath/$exercise/$script))
	if [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex04
	script="MAC.sh"
	exercise="ex04"
	commandDiff=$(diff <(bash $correctPath/$exercise/$script) <(bash $currentPath/$exercise/$script))
	if [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex05
	exercise="ex05"
	pass="True"
	cd $currentPath/$exercise
	studentOut=$(ls -lRa *MaRV* | cat -e)
	studentContents=$(cat *MaRV*)
	if [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
		pass="False"
	fi
	cd $currentDir
	cd $correctPath/$exercise
	correctOut=$(ls -lRa *MaRV* | cat -e)
	correctContents=$(cat *MaRV*)
	cd $currentDir
	if [ "$(echo $studentOut | cut -d " " -f 1)" != "$(echo $correctOut | cut -d " " -f 1)" ]; then
		echo $exercise - $(readJSON "errorWrongPermissions") >> $errorFile
		pass="False"
	elif [ "$(echo $studentOut | cut -d " " -f 5)" != "$(echo $correctOut | cut -d " " -f 5)" ]; then
		echo $exercise - $(readJSON "errorWrongFileSize") >> $errorFile
		pass="False"
	elif [ "$(echo $studentOut | cut -d " " -f 9)" != "$(echo $correctOut | cut -d " " -f 9)" ]; then
		echo $exercise - $(readJSON "errorWrongFileName") >> $errorFile
		pass="False"
	elif [ "$studentContents" != "$correctContents" ]; then
		echo $exercise - $(readJSON "errorFileContentsIncorrect") >> $errorFile
		pass="False"
	fi

	if [ "$pass" == "True" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
	fi

	# ex06
	script="skip.sh"
	exercise="ex06"
	commandDiff=$(diff <(bash $correctPath/$exercise/$script) <(bash $currentPath/$exercise/$script))
	if [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex07
	script="r_dwssap.sh"
	exercise="ex07"
	# permissions didn't need to be configured correctly for 07 - maybe true for rest
	FT_LINE1=15
	FT_LINE2=20
	export FT_LINE1
	export FT_LINE2
	commandDiff=$(diff <(./$correctPath/$exercise/$script) <(./$currentPath/$exercise/$script))
	if [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex08
	script="add_chelou.sh"
	exercise="ex08"
	FT_NBR1="idk how to"
	FT_NBR2=rcrdmddd
	export FT_NBR1
	export FT_NBR2
	#commandDiff=$(diff <(bash $currentPath/$exercise/$script) <(bash $correctPath/$exercise/$script))
	echo $exercise - "I don't know"
}

main