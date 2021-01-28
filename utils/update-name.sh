#!/bin/bash

# Usage:
# 
# update-name.sh FOLDER NAME VALUE

FOLDER=$1 
NAME=$2 
VALUE=$3

find $FOLDER -type f -exec sed -i 's/{'$NAME'}/'$VALUE'/g' {} \;
