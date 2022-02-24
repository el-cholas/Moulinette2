#!/bin/bash

# GLOBAL VARS
languagesDir="languages/"
projectDir="project/"
tmp="NULL" # This is used because I cannot return variables in bash
errorFile="errors.txt"
userPreferencesFile="preferences.json"
currentDir=$(pwd)

# Text colouring
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Defaults, these will be overwritten if in user preferences file
currentLanguage="ru"
showMains="False"  # This saves the main files generated if True
langFile=$languagesDir$currentLanguage.json


main () {
	git pull

	# Setup defaults
	if [ -f "$userPreferencesFile" ]; then
		currentLanguage=$(readJSON "language" $userPreferencesFile)
		showMains=$(readJSON "showMains" $userPreferencesFile)
	else
        createDefaults
    fi
    langFile=$languagesDir$currentLanguage.json

	chooseExercise
	if ! [ -d "$projectDir" ]; then
        projectDirEmpty
        local dirEmpty="True"
    else
    	local dirEmpty="False"
    fi
    echo -e "$(readJSON "errorLogTitle")" > $errorFile
	$tmp $tmp

	# Condition to remove contents if the project was downloaded by this current program
	if [ "$dirEmpty" == "True" ]; then
		rm -rf $projectDir
	fi
	echo -e "\n$(readJSON "createdBy")\n"
}

createDefaults () {
	chooseLanguage
	echo -e '{\n\t"language": "'$currentLanguage'",' > $userPreferencesFile
	echo -e '\t"showMains": "'$showMains'"\n}' >> $userPreferencesFile
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
	# Usage is ' $(readJSON "key" "path.json") '
	cd $currentDir
	local fieldName=$1

	if [ ${#2} == "0" ]; then
		local filename=$langFile
	else
		local filename=$2
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
	tmp=$langFile

	# Loop through language files and print them out
	for languageName in "${files[@]}"
	do
		langFile=$languagesDir$languageName.json
		echo $fileIndex $(readJSON languageName)
		fileIndex=$(($fileIndex + 1))
	done

	# Reset the current language var
	langFile=$tmp
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

	checkNorminette

	gccOut=$(gcc -Wall -Wextra -Werror $cfiles)

	if [ "${#gccOut}" == "0" ]; then
		echo $(readJSON "compileOK")
		rm "a.out"  # delete a.out since compile is ok
	else
		gccOut=$(gcc -Wall -Wextra -Werror $cfiles)
	fi
}

checkNorminette () {
	# CD MAKES ME SCARED
	cd $projectDir
	local normOutputLineCount=$(norminette -R CheckForbiddenSourceHeader | wc -l | sed "s/ //g")
	local normOutputOKcount=$(norminette -R CheckForbiddenSourceHeader | grep "OK!" | wc -l | sed "s/ //g")
	echo ""
	if [ "$normOutputOKcount" != "$normOutputLineCount" ]; then
		norminette -R CheckForbiddenSourceHeader | grep -v "OK!"
	else 
		echo $(readJSON "norminetteOK")
	fi
	cd $currentDir
	# CD MAKES ME SCARED
}

C-executer () {
	# Usage
	# C-executer "script file name" "function" "declaredFunction" "exercise" "correctDir" "uploadedDir"
	# Example usage
	# C-executer "ft_putchar.c" "ft_putchar('C')" "void ft_putchar(char c)" "ex00" "correctDir" "uploadedDir"
	#
	# Other Usage (this is specific to C02 ex12 where different runs will have different outputs)
	# The last 2 optional variables will be a cut command where the d is $7 and f is $8
	#
	# I only created this function after c02 because I am a dumbass and forgot that I can put ""
	# around inputted variables to seperate them.
	local mainDir="mains"
	local script=$1
	local function=$2
	local declaredFunction=$3
	local exercise=$4
	local correctPath=$5
	local currentPath=$6
	local compileError=""
	local commandDiff=""
	local main="main.c"

	# check if main dir exists
	if [ "$showMains" == "True" ]; then
		if ! [ -d "$mainDir" ]; then
        	mkdir $mainDir
       	fi
        main="$mainDir/main-$exercise.c"
    fi
	
	# create main
	# If you get an error where new lines aren't printed, change the below echo to printf as it is far more reliable
	echo -e "$declaredFunction;\nint main(void)\n{\n\t$function;\n\treturn (0);\n}" > $main

	gcc -Wall -Wextra -Werror $main $correctPath/$exercise/$script

	# check for $7 and &8
    if [ ${#7} == "0" ] && [ ${#8} == "0" ]; then
		local correctOut=$(./a.out)
	else
		local correctOut=$(./a.out | cut -d "$7" -f $8)
	fi

	compileError=$(( gcc -Wall -Wextra -Werror $main $currentPath/$exercise/$script ) 2>&1)
	#local studentOut=$(timeout 1s -c './a.out') - this is to exit if the timer is reached

	# check for $7 and &8
    if [ ${#7} == "0" ] && [ ${#8} == "0" ]; then
		local studentOut=$(./a.out)
	else
		local studentOut=$(./a.out | cut -d "$7" -f $8)
	fi

	commandDiff=$(diff <(echo "$correctOut" ) <(echo "$studentOut"))
	rm a.out
	# if length is 0
	if [ ${#commandDiff} == "0" ] && [ ${#compileError} == "0" ]; then
		# Colours
		echo -e $exercise - ${GREEN}"$(readJSON "PASS")${NC}"
	else
		# Colours
		echo -e $exercise - ${RED}"$(readJSON "FAIL")${NC}"
		echo -e "\n$exercise" >> $errorFile
		if [ ${#commandDiff} == "0" ]; then
			echo -e "diff $(readJSON "PASS") :D" >> $errorFile
		else
			echo -e "diff $(readJSON "FAIL") :(\n$commandDiff" >> $errorFile
		fi
		if [ ${#compileError} == "0" ]; then
			echo -e "compile $(readJSON "PASS") :D" >> $errorFile
		else
			echo -e "compile $(readJSON "FAIL") :(\n$compileError" >> $errorFile
		fi
	fi

	# check if main dir exists
	if [ "$showMains" != "True" ]; then
        rm $main
    fi
}

c-piscine-c-00 () {
	local correctPath=".DS_Store/$1"
	local currentPath=${projectDir///}

	local script=""
	local exercise=""

	checkNorminette

	# ex 00
	script="ft_putchar.c"
	function="ft_putchar('C')"
	declaredFunction="void ft_putchar(char c)"
	exercise="ex00"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 01
	script="ft_print_alphabet.c"
	function="ft_print_alphabet()"
	declaredFunction="void ft_print_alphabet(void)"
	exercise="ex01"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 02
	script="ft_print_reverse_alphabet.c"
	function="ft_print_reverse_alphabet()"
	declaredFunction="void ft_print_reverse_alphabet(void)"
	exercise="ex02"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 03
	script="ft_print_numbers.c"
	function="ft_print_numbers()"
	declaredFunction="void ft_print_numbers(void)"
	exercise="ex03"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 04
	script="ft_is_negative.c"
	function="ft_is_negative(-1); ft_is_negative(0); ft_is_negative(1); ft_is_negative(2147483647); ft_is_negative(-2147483648); ft_is_negative(42)"
	declaredFunction="void ft_is_negative(int n)"
	exercise="ex04"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 05
	script="ft_print_comb.c"
	function="ft_print_comb()"
	declaredFunction="void ft_print_comb(void)"
	exercise="ex05"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 06
	script="ft_print_comb2.c"
	function="ft_print_comb2()"
	declaredFunction="void ft_print_comb2(void)"
	exercise="ex06"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 07
	script="ft_putnbr.c"
	function="ft_putnbr(0); ft_putnbr(-1); ft_putnbr(1); ft_putnbr(2147483647); ft_putnbr(-2147483648); ft_putnbr(420); ft_putnbr(69)"
	declaredFunction="void ft_putnbr(int nb)"
	exercise="ex07"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 08
	script="ft_print_combn.c"
	function="ft_print_combn(1); ft_print_combn(2); ft_print_combn(3); ft_print_combn(4); ft_print_combn(5); ft_print_combn(6); ft_print_combn(7); ft_print_combn(8); ft_print_combn(9)"
	declaredFunction="void ft_print_combn(int n)"
	exercise="ex08"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"
}

c-piscine-c-01 () {
	local correctPath=".DS_Store/$1"
	local currentPath=${projectDir///}

	local script=""
	local exercise=""

	checkNorminette

	# ex 00
	script="ft_ft.c"
	function='int i = 36; ft_ft(&i); printf("%d", i)'
	declaredFunction="#include <stdio.h>\nvoid ft_ft(int *nbr)"
	exercise="ex00"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 01
	script="ft_ultimate_ft.c"
	function='int *********p_nbr; int ********p_nbr2; int *******p_nbr3; int ******p_nbr4; int *****p_nbr5; int ****p_nbr6; int ***p_nbr7; int **p_nbr8; int *p_nbr9; int nbr; nbr = 21; p_nbr9 = &nbr; p_nbr8 = &p_nbr9; p_nbr7 = &p_nbr8; p_nbr6 = &p_nbr7; p_nbr5 = &p_nbr6; p_nbr4 = &p_nbr5; p_nbr3 = &p_nbr4; p_nbr2 = &p_nbr3; p_nbr = &p_nbr2; printf("%d", nbr); ft_ultimate_ft(p_nbr); printf("%d", nbr);'
	declaredFunction="#include <stdio.h>\nvoid ft_ultimate_ft(int *********nbr)"
	exercise="ex01"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 02
	script="ft_swap.c"
	function='int a = 36; int b = 42; ft_swap(&a, &b); printf("%d, %d", a, b)'
	declaredFunction="#include <stdio.h>\nvoid ft_swap(int *a, int *b);"
	exercise="ex02"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 03
	script="ft_div_mod.c"
	function='int a = 36; int b = 42; int div; int mod; ft_div_mod(a, b, &div, &mod); printf("%d, %d", div, mod)'
	declaredFunction="#include <stdio.h>\nvoid ft_div_mod(int a, int b, int *div, int *mod);"
	exercise="ex03"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 04
	script="ft_ultimate_div_mod.c"
	function='int a = 36; int b = 42; ft_ultimate_div_mod(&a, &b); printf("%d, %d", a, b)'
	declaredFunction="#include <stdio.h>\nvoid ft_ultimate_div_mod(int *a, int *b);"
	exercise="ex04"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 05
	script="ft_putstr.c"
	function='ft_putstr("Hello"); ft_putstr("Hire "); ft_putstr(""); ft_putstr(" Me")'
	declaredFunction="#include <stdio.h>\nvoid ft_putstr(char *str)"
	exercise="ex05"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 06
	script="ft_strlen.c"
	function='printf("%d, %d, %d, %d, %d", ft_strlen(""), ft_strlen("Hello"), ft_strlen("-1"), ft_strlen("I havent slept yet"), ft_strlen(""))'
	declaredFunction="#include <stdio.h>\nint ft_strlen(char *str);"
	exercise="ex06"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 07
	script="ft_rev_int_tab.c"
	function='int length = 1000; int tab[length]; int i = 0; while (i < length){tab[i] = i; i++;}ft_rev_int_tab(tab, length); i = 0; while (i < length){printf("%d", tab[i]); i++;}'
	declaredFunction="#include <stdio.h>\nvoid ft_rev_int_tab(int *tab, int size);"
	exercise="ex07"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 08
	script="ft_sort_int_tab.c"
	function='int length = 1000; int tab[length]; int i = 0; while (i < length){tab[i] = length - i; i++;}ft_sort_int_tab(tab, length); i = 0; while (i < length){printf("%d", tab[i]); i++;}'
	declaredFunction="#include <stdio.h>\nvoid ft_sort_int_tab(int *tab, int size);"
	exercise="ex08"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"
}

c-piscine-c-02 () {
	local correctPath=".DS_Store/$1"
	local currentPath=${projectDir///}

	local script=""
	local exercise=""

	local testWeirdString="char str1[] = {0x42, 0x6f, 0x6e, 0x6a, 0x6f, 0x75, 0x72, 0x20, 0x6c, 0x65, 0x73, 0x20, 0x61, 0x6d, 0x69, 0x6e, 0x63, 0x68, 0x65, 0x73, 0x09, 0x0a, 0x09, 0x63, 0x20, 0x20, 0x65, 0x73, 0x74, 0x20, 0x66, 0x6f, 0x75, 0x09, 0x74, 0x6f, 0x75, 0x74, 0x09, 0x63, 0x65, 0x20, 0x71, 0x75, 0x20, 0x6f, 0x6e, 0x20, 0x70, 0x65, 0x75, 0x74, 0x20, 0x66, 0x61, 0x69, 0x72, 0x65, 0x20, 0x61, 0x76, 0x65, 0x63, 0x09, 0x0a, 0x09, 0x70, 0x72, 0x69, 0x6e, 0x74, 0x5f, 0x6d, 0x65, 0x6d, 0x6f, 0x72, 0x79, 0x0a, 0x0a, 0x0a, 0x09, 0x6c, 0x6f, 0x6c, 0x2e, 0x6c, 0x6f, 0x6c, 0x0a, 0x20, 0x00};\n"

	checkNorminette

	# ex 00
	script="ft_strcpy.c"
	function=$testWeirdString'char dest[] = "";\nchar src[] = "Hello";\nprintf("%s, %s", src, dest);\nft_strcpy(dest, src);\nprintf("%s, %s", src, dest);\nft_strcpy(dest, str1);\nprintf("%s, %s", str1, dest);'
	declaredFunction="#include <stdio.h>\nchar *ft_strcpy(char *dest, char *src)"
	exercise="ex00"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 01
	script="ft_strncpy.c"
	function=$testWeirdString'char dest[] = "";\nchar src[] = "Hello";\nprintf("%s, %s", src, dest);\nft_strncpy(dest, src, 0);\nprintf("%s, %s", src, dest);\nft_strncpy(dest, str1, 10);\nprintf("%s, %s", str1, dest);'
	declaredFunction="#include <stdio.h>\nchar *ft_strncpy(char *dest, char *src, unsigned int n);"
	exercise="ex01"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 02
	script="ft_str_is_alpha.c"
	function=$testWeirdString'printf("%d, %d, %d, %d, %d", ft_str_is_alpha(""), ft_str_is_alpha("abc"), ft_str_is_alpha("ABC"), ft_str_is_alpha("123"), ft_str_is_alpha(str1));'
	declaredFunction="#include <stdio.h>\nint ft_str_is_alpha(char *str);"
	exercise="ex02"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 03
	script="ft_str_is_numeric.c"
	function=$testWeirdString'printf("%d, %d, %d, %d, %d", ft_str_is_numeric(""), ft_str_is_numeric("abc"), ft_str_is_numeric("ABC"), ft_str_is_numeric("123"), ft_str_is_numeric(str1))'
	declaredFunction="#include <stdio.h>\nint ft_str_is_numeric(char *str);"
	exercise="ex03"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 04
	script="ft_str_is_lowercase.c"
	function=$testWeirdString'printf("%d, %d, %d, %d, %d", ft_str_is_lowercase(""), ft_str_is_lowercase("abc"), ft_str_is_lowercase("ABC"), ft_str_is_lowercase("123"), ft_str_is_lowercase(str1))'
	declaredFunction="#include <stdio.h>\nint ft_str_is_lowercase(char *str);"
	exercise="ex04"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 05
	script="ft_str_is_uppercase.c"
	function=$testWeirdString'printf("%d, %d, %d, %d, %d", ft_str_is_uppercase(""), ft_str_is_uppercase("abc"), ft_str_is_uppercase("ABC"), ft_str_is_uppercase("123"), ft_str_is_uppercase(str1))'
	declaredFunction="#include <stdio.h>\nint ft_str_is_uppercase(char *str);"
	exercise="ex05"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 06
	script="ft_str_is_printable.c"
	function=$testWeirdString'printf("%d, %d, %d, %d, %d", ft_str_is_printable(""), ft_str_is_printable("abc"), ft_str_is_printable("ABC"), ft_str_is_printable("123"), ft_str_is_printable(str1))'
	declaredFunction="#include <stdio.h>\nint ft_str_is_printable(char *str);"
	exercise="ex06"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 07
	script="ft_strupcase.c"
	function=$testWeirdString'printf("%s, %s, %s, %s, %s", ft_strupcase(""), ft_strupcase("abc"), ft_strupcase("ABC"), ft_strupcase("123"), ft_strupcase(str1))'
	declaredFunction="#include <stdio.h>\nchar *ft_strupcase(char *str);"
	exercise="ex07"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 08
	script="ft_strlowcase.c"
	function=$testWeirdString'printf("%s, %s, %s, %s, %s", ft_strlowcase(""), ft_strlowcase("abc"), ft_strlowcase("ABC"), ft_strlowcase("123"), ft_strlowcase(str1))'
	declaredFunction="#include <stdio.h>\nchar *ft_strlowcase(char *str);"
	exercise="ex08"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 09
	script="ft_strcapitalize.c"
	function=$testWeirdString'printf("%s, %s, %s, %s, %s", ft_strcapitalize(""), ft_strcapitalize("salut, comment tu vas ? 42mots quarante-deux; cinquante+et+un"), ft_strcapitalize("ABC"), ft_strcapitalize("123"), ft_strcapitalize(str1))'
	declaredFunction="#include <stdio.h>\nchar *ft_strcapitalize(char *str);"
	exercise="ex09"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 10
	script="ft_strlcpy.c"
	function=$testWeirdString'char dest[] = "";\nchar src[] = "Hello";\nprintf("%s, %s", src, dest);\nft_strlcpy(dest, src, 6);\nprintf("%s, %s", src, dest);\nft_strlcpy(dest, str1, 92);\nprintf("%s, %s", str1, dest);\nft_strlcpy(dest, src, 5);'
	declaredFunction="#include <stdio.h>\nunsigned int ft_strlcpy(char *dest, char *src, unsigned int size);"
	exercise="ex10"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 11
	script="ft_putstr_non_printable.c"
	function=$testWeirdString'ft_putstr_non_printable("");\nft_putstr_non_printable("abc");\nft_putstr_non_printable("ABC");\nft_putstr_non_printable("123");\nft_putstr_non_printable(str1);\n'
	declaredFunction="#include <stdio.h>\nvoid ft_putstr_non_printable(char *str);"
	exercise="ex11"
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath"

	# ex 12
	script="ft_print_memory.c"
	function=$testWeirdString'ft_print_memory((void *)&str1, 8);\nft_print_memory((void *)&str1, 16);\nft_print_memory((void *)&str1, 0);\n'
	declaredFunction="#include <stdio.h>\nvoid	*ft_print_memory(void *addr, unsigned int size);"
	exercise="ex12"
	# Compares everything but first column
	C-executer "$script" "$function" "$declaredFunction" "$exercise" "$correctPath" "$currentPath" ":" "2-"
}

main