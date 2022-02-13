#!/bin/bash

# GLOBAL VARS
languagesDir="languages/"
secret=".secret/"
currentLanguage="en"


main () {
	chooseLanguage
}

chooseLanguage () {
	local files=$(find $languagesDir -name "*.json" -type f -exec basename {} .json ";")
	local fileIndex=1
	for languageName in "${files[@]}"
	do
		echo $fileIndex $languageName
		fileIndex=$(($fileIndex + 1))
	done

	echo -n "$(readJSON chooseLanguage) "
	read languageIndex

	if (( $((languageIndex)) <=  fileIndex - 1 && $((languageIndex)) >= 1 ));
	then
		echo "just correct"
	fi

	echo $languageIndex
}

readJSON () {
	local fieldName=$1

	# If $2 is an empty variable, set it as the default language
	if [ -z "$2" ]
	then
    	filename="$languagesDir$currentLanguage.json"
	else
		filename="$languagesDir$2.json"
	fi
	grep -o '"'$fieldName'": "[^"]*' $filename | grep -o '[^"]*$'
}

main