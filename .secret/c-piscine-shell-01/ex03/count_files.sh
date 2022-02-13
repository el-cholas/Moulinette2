#!/bin/sh

find . -type f -o -type d | wc -l | sed 's/ //g'

# sed uses regex, regex always starts with s/ and ends with /g
# the " /" in the middle means replace every occurrence of " " with ""