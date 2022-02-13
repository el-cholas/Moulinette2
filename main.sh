#!/bin/bash

# GLOBAL VARS
languagesDir="languages/"
secret=".secret/"
currentLanguage="en"

chooseLanguage () {
	files=$(find $languagesDir -name "*.json" -type f -exec basename {} .json ";")
	files=($ls $languagesDir) | sed "s/ /\n/g"
	fileIndex=1
	for languageName in "${files[@]}"
	do
		echo $langageName
	done
}

readJSON () {
	local filename="$languagesDir$currentLanguage.json"
	local fieldName=$1
	grep -o '"'$fieldName'": "[^"]*' $filename | grep -o '[^"]*$'
}

chooseLanguage