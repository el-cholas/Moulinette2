#!/bin/bash

# GLOBAL VARS
languagesDir="languages/"
currentLanguage="en"
projectDir="project/"
tmp="NULL" # This is used because I cannot return variables in bash
errorFile="errors.txt"
currentDir=$(pwd)


main () {
	git pull
	chooseLanguage
	chooseExercise
	if ! [ -d "$projectDir" ]; then
        projectDirEmpty
        local dirEmpty="True"
    else
    	local dirEmpty="False"
    fi
    echo "$(readJSON "errorLogTitle")" > $errorFile
	$tmp $tmp

	# Condition to remove contents if the project was downloaded by this current program
	if [ "$dirEmpty" == "True" ]; then
		rm -rf $projectDir
	fi
	echo ""
	echo "$(readJSON "createdBy")"
	echo ""
}

projectDirEmpty () {
    echo -n "$(readJSON "pasteGitURL") "
    read gitURL
    if $(git clone $gitURL); then
        # This gets the name of the folder in the git then removes the .git
        gitFolderName=$(echo $gitURL | rev | cut -d '/' -f1 | rev | sed 's/.git//g')
        mv $gitFolderName $projectDir
        rm -rf $projectDir/.git
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
    	filename="$currentDir/$languagesDir$currentLanguage.json"
	else
		filename="$currentDir/$languagesDir$2.json"
	fi
	grep -o '"'$fieldName'": "[^"]*' $filename | grep -o '[^"]*$'
}

# MENUS AND SELECTION STUFF, THESE COMMANDS ARE ALL THE SAME
chooseLanguage () {
	# If I could I would make a function to list an array and make a selection so I can resuse this code super easily
	# But bash sucks ass a bit with storing and returning variable

	# Store all json files into an array
	local files=($(find $languagesDir -name "*.json" -type f -exec basename {} .json ";"))
	local fileIndex=1
	echo ""

	# Set the tmp variable as the current language so I can reset it after
	tmp=$currentLanguage

	# Loop through language files and print them out
	for languageName in "${files[@]}"
	do
		currentLanguage=$languageName
		echo $fileIndex $(readJSON languageName)
		fileIndex=$(($fileIndex + 1))
	done

	# Reset the current language var
	currentLanguage=$tmp
	# Ask user for language selection
	echo -n "$(readJSON chooseLanguage) "
	read languageIndex
	echo ""

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
	local files=("C" $(find ".DS_Store/" -name "c-piscine*" -type d -exec basename {} ";"))
	local fileIndex=1
	echo ""
	# Loop through language files and print them out
	for languageName in "${files[@]}"
	do
		if [ "$fileIndex" == "1" ]; then
			echo $fileIndex $languageName $(readJSON "testAnyC")
		else
			echo $fileIndex $languageName
		fi
		fileIndex=$(($fileIndex + 1))
	done

	# Ask user for language selection
	echo -n "$(readJSON chooseExercise) "
	read languageIndex
	echo ""
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
c-piscine-shell-00 () {
	local correctPath=".DS_Store/$1"
	local currentPath=${projectDir///}

	local script=""
	local exercise=""
	local commandDiff=""

	# ex00
	script="z"
	exercise="ex00"
	commandDiff=$(diff <(cat $correctPath/$exercise/$script) <(cat $currentPath/$exercise/$script))
	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex01
	exercise="ex01"
	script="ls -l"
	studentDir="student/"
	correctDir="correct/"
	mkdir $studentDir $correctDir
	tar -xf $correctPath/$exercise/testShell00.tar -C $correctDir
	tar -xf $currentPath/$exercise/testShell00.tar -C $studentDir
	correctOut=$($script $correctDir)
	studentOut=$($script $studentDir)

	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 3)" != "$(echo $correctOut | cut -d " " -f 3)" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorWrongPermissions") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 4)" != "$(echo $correctOut | cut -d " " -f 4)" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorIncorrectHardLinks") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 7)" != "$(echo $correctOut | cut -d " " -f 7)" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorWrongFileSize") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 8,9)" != "$(echo $correctOut | cut -d " " -f 8,9)" ]; then
		# Here I should validate whether the input number from the student is a valid year or the correct hour
		# But I am lazy
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorIncorrectDate") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 11)" != "$(echo $correctOut | cut -d " " -f 11)" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorWrongFileName") >> $errorFile
	else
		echo $exercise - $(readJSON "PASS")
	fi
	rm -rf $studentDir $correctDir

	# ex02
	exercise="ex02"
	script="ls -l"
	studentDir="student/"
	correctDir="correct/"
	mkdir $studentDir $correctDir
	tar -xf $correctPath/$exercise/exo2.tar -C $correctDir
	tar -xf $currentPath/$exercise/exo2.tar -C $studentDir
	correctOut=$($script $correctDir)
	studentOut=$($script $studentDir)

	# This currently compares all file sizes exacly even though it shouldn't, I may or may not fix this in the future

	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 3)" != "$(echo $correctOut | cut -d " " -f 3)" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorWrongPermissions") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 4)" != "$(echo $correctOut | cut -d " " -f 4)" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorIncorrectHardLinks") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 7)" != "$(echo $correctOut | cut -d " " -f 7)" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorWrongFileSize") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 8,9)" != "$(echo $correctOut | cut -d " " -f 8,9)" ]; then
		# Here I should validate whether the input number from the student is a valid year or the correct hour
		# But I am lazy
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorIncorrectDate") >> $errorFile
	elif [ "$(echo $studentOut | cut -d " " -f 11)" != "$(echo $correctOut | cut -d " " -f 11)" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorWrongFileName") >> $errorFile
	else
		echo $exercise - $(readJSON "PASS")
	fi
	rm -rf $studentDir $correctDir

	# ex03
	exercise="ex03"
	script="id_rsa_pub"


	if test -f "$currentPath/$exercise/$script"; then
    	echo $exercise - $(readJSON "PASS")
    else
    	echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	fi

	# ex04
	script="midLS"
	exercise="ex04"
	commandDiff=$(diff <(bash $correctPath/$exercise/$script) <(bash $currentPath/$exercise/$script))
	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex05
	script="git_commit.sh | cat -e"
	exercise="ex05"
	commandDiff=$(diff <(bash $correctPath/$exercise/$script) <(bash $currentPath/$exercise/$script))
	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex06
	script="git_ignore.sh | cat -e"
	exercise="ex06"
	touch "#IGNOREMEPLS" "#IGNOREME_"
	commandDiff=$(diff <(bash $correctPath/$exercise/$script) <(bash $currentPath/$exercise/$script))
	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi
	rm "#IGNOREMEPLS" "#IGNOREME_"

	# ex07
	script="b"
	exercise="ex07"
	commandDiff=$(diff <(cat $correctPath/$exercise/$script) <(cat $currentPath/$exercise/$script))
	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi

	# ex08
	script="clean"
	exercise="ex08"
	touch "hello1~" "hello2~" "#hello1#" "#hello2#" "~hello1" "~hello2" "hello1#" "hello2#" "#hello1" "#hello2"
	commandDiff=$(diff <(cat $correctPath/$exercise/$script) <(cat $currentPath/$exercise/$script))
	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi
	rm "hello1~" "hello2~" "#hello1#" "#hello2#" "~hello1" "~hello2" "hello1#" "hello2#" "#hello1" "#hello2"

	# ex09
	# I don't really know how to test this, but this should be sufficient
	script="ft_magic"
	exercise="ex09"
	commandDiff=$(diff <(cat $correctPath/$exercise/$script) <(cat $currentPath/$exercise/$script))
	if  [ "$?" != "0" ]; then
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $(readJSON "errorFailedToExecute") >> $errorFile
	elif [ ${#commandDiff} == "0" ]; then
		echo $exercise - $(readJSON "PASS")
	else
		echo $exercise - $(readJSON "FAIL")
		echo $exercise - $commandDiff >> $errorFile
	fi
}

c-piscine-shell-01 () {
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
	chmod a+x $currentPath/$exercise/$script 2>> $errorFile
	commandDiff=$(diff <(./$correctPath/$exercise/$script) <(./$currentPath/$exercise/$script)) 2>> $errorFile
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
	chmod a+x $currentPath/$exercise/$script 2>> $errorFile
	commandDiff=$(diff <(./$correctPath/$exercise/$script) <(./$currentPath/$exercise/$script)) 2>> $errorFile
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
	chmod a+x $currentPath/$exercise/$script 2>> $errorFile
	commandDiff=$(diff <(./$correctPath/$exercise/$script) <(./$currentPath/$exercise/$script)) 2>> $errorFile
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
	commandDiff=$(diff <(bash $correctPath/$exercise/$script) <(bash $currentPath/$exercise/$script)) 2>> $errorFile
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
	cd $currentPath/$exercise 2>>  $errorFile
	studentOut=$(ls -lRa *MaRV* | cat -e) 2>> $errorFile
	studentContents=$(cat *MaRV*) 2>> $errorFile
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
	commandDiff=$(diff <(bash $correctPath/$exercise/$script) <(bash $currentPath/$exercise/$script)) 2>> $errorFile
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
	chmod a+x $currentPath/$exercise/$script 2>> $errorFile
	commandDiff=$(diff <(./$correctPath/$exercise/$script) <(./$currentPath/$exercise/$script)) 2>> $errorFile
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
	#commandDiff=$(diff <(bash $currentPath/$exercise/$script) <(bash $correctPath/$exercise/$script)) >> $errorFile
	echo $exercise - $(readJSON "notYetMarked")
}

C () {
	# This will test for compliation errors for any c code that fucking moulinette and norminette will pick out
	# PS I fucking hate moulinette

	local cfiles=$(find $projectDir -name "*.c" -type f)

	# CD MAKES ME SCARED
	cd $projectDir
	normOutputLineCount=$(norminette -R CheckForbiddenSourceHeader | wc -l | sed "s/ //g")
	normOutputOKcount=$(norminette -R CheckForbiddenSourceHeader | grep "OK!" | wc -l | sed "s/ //g")
	echo ""
	if [ "$normOutputOKcount" != "$normOutputLineCount" ]; then
		norminette -R CheckForbiddenSourceHeader | grep -v "OK!"
	else 
		echo $(readJSON "norminetteOK")
	fi
	cd $currentDir
	# CD MAKES ME SCARED

	gccOut=$(gcc -Wall -Wextra -Werror $cfiles)

	if [ "${#gccOut}" == "0" ]; then
		echo $(readJSON "compileOK")
		rm "a.out"  # delete a.out since compile is ok
	else
		gccOut=$(gcc -Wall -Wextra -Werror $cfiles)
	fi
}

c-piscine-c-00 () {
	local correctPath=".DS_Store/$1"
	local currentPath=${projectDir///}

	local script=""
	local exercise=""
	local commandDiff=""
	echo ""
	echo $1 - $(readJSON "notYetMarked")
	echo $(readJSON "executing") - $(readJSON "testAnyC")
	C
}

c-piscine-c-01 () {
	local correctPath=".DS_Store/$1"
	local currentPath=${projectDir///}

	local script=""
	local exercise=""
	local commandDiff=""
	echo ""
	echo $1 - $(readJSON "notYetMarked")
	echo $(readJSON "executing") - $(readJSON "testAnyC")
	C
}

main