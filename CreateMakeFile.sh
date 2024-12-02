#!/bin/bash

HelpMenu="
  // CreateMakeFiles // 
  
  Usage:
  CreateMakeFiles <extension> [<project name>] [<binary filename>]
  
  Supported languages: C, C++, Java

  To use custom values:
    - create '~/.config/CreateMakeFiles/CreateMakeFiles.conf' 
      - Author=\"<author name>\"
      - bin=\"<bin filename>\"
"

if [[ $# = 0 ]]; then # 0 ARGS
  echo "$HelpMenu"
  exit
fi

# 1 ARG

if [[ $1 = "-h" ]]; then # -h
  echo "$HelpMenu"
  exit
fi

Extension=$1 # Loads Extension from $1
case "$Extension" in
"c")
  echo "Creating Makefile for C project..."
  ;;
"cpp")
  echo "Creating Makefile for C++ project..."
  ;;
"java")
  echo "Creating Makefile for Java project..."
  ;;
*)
  echo "Extension $Extension is not supported!"
  echo "Aborting."
  exit
  ;;
esac

. ~/.config/CreateMakeFiles/CreateMakeFiles.conf # Include a config

if [[ config = true ]]; then
  echo "Config was found..."
fi

while [[ $# > 0 ]]; do # 2+ ARGS
  shift                # Extension is not $1. Working with other flags
  case "$1" in
  "-n" | "--Name")
    ProjectName=$2
    echo "Project name: $ProjectName"
    ;;
  "-a" | "--Author")
    Author=$2
    echo "Author: $Author"
    ;;
  "-b" | "--BinFilename")
    Author=$2
    echo "Bin filename: $BinFilename"
    ;;
  *) ;;
  esac
done

# Defaults
if [[ -z $ProjectName ]]; then
  ProjectName=$(basename "$(pwd)")
fi
if [[ -z $BinFilename ]]; then
  BinFilename="\$(NAME).bin"
fi
if [[ -z $Author ]]; then
  Author=$(whoami)
fi

# All info we need from the user is: ProjectName, Author, BinFilename, Extension
# Cannot run with no flag
# With one flag it's -h or extension without flag
# With more flags 1. Load the config 2. load the vars with from flags 3. Defaults

for i in *.$Extension; do # Nacteni source files do array
  [ -f "$i" ] || break
  SourceFiles+=("$i")
done
if [[ ${#SourceFiles[@]} == 0 ]]; then # If no source files are found
  echo "ERROR: No files in $pwd with extension .$Extension"
  echo "Aborting"
  exit
fi

case "$Extension" in
"c")
  CC="gcc"
  Flags="-std=c99 -pedantic -Wall -g"
  Compile="\$(CC) $Flags \$(SOURCE_FILES) -o \$(EXE_FILE)"
  ;;
"cpp")
  CC="g++"
  Flags="-g -std=c++14 -Wall -Werror -pedantic"
  Compile="\$(CC) $Flags \$(SOURCE_FILES) -o \$(EXE_FILE)"
  ;;
"java")
  CC="javac"
  Compile="\$(CC) \$(SOURCE_FILES)"
  ;;
*)
  echo "ERROR: unsupported extension!"
  exit
  ;;
esac

echo "# Projekt: $ProjectName
# Autor: $Author

# VARS
NAME=$ProjectName
SOURCE_FILES=${SourceFiles[*]}
CC=$CC

EXE_FILE=$BinFilename
ALL_FILES=./*

compile:
	$Compile

run:
	./\$(EXE_FILE)


clear-exe:
	rm \$(EXE_FILE)

clear-bin:
	rm -rf bin/ 
	rm -rf obj/

clear-pack:
	rm \$(NAME).tar.gz
	rm \$(NAME).zip

pack: clear-bin 
	rm \$(NAME)
	tar cvzf \$(NAME).tar.gz \$(ALL_FILES)
	zip \$(NAME).zip \$(ALL_FILES)

clear: clear-bin clear-pack clear-exe
" >Makefile

if [ -f Makefile ]; then
  echo "Makefile has been created."
  exit
fi

echo "ERROR: Makefile has not been created."
