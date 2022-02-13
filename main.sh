#!/bin/bash

# GLOBAL VARS
languagesDir="languages/"
currentLanguage="en"
projectDir="project/"
tmp="NULL" # This is used because I cannot return variables in bash


main () {
	chooseLanguage
	chooseExercise
	if [ -d "$projectDir" ]; then
        cd $projectDir
		git pull
        cd ..
    else
        projectDirEmpty
    fi
	$tmp
}

projectDirEmpty () {
    echo -n "$(readJSON "pasteGitURL") "
    read gitURL
    if $(git clone $gitURL); then
        # This gets the name of the folder in the git then removes the .git
        gitFolderName=$(echo $gitURL | rev | cut -d '/' -f1 | rev | sed 's/.git//g')
        mv $gitFolderName $GITDIR
    else
    	echo "$(readJSON "gitCloneFailed") "
    fi
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
	local files=($(find ".secret/" -name "c-piscine*" -type d -exec basename {} ";"))
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

# Exercises
c-piscine-shell-00 () {
	local var=""
}

main