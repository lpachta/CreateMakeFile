#!/bin/bash

BOLD="\033[1m"
RESET="\033[0m"

HelpMenu="
  
  ╭───────────────────────────────╮
  │   --== ${BOLD}CreateMakeFiles${RESET} ==--   │
  ╰───────────────────────────────╯

  CreateMakeFiles is a bash script used for automatic creating of a Makefile.

  Supported languages: C, C++, Java 
  
  This info:
    CreateMakeFiles -h

  Usage:
    CreateMakeFile <c | cpp | java> [--flag \"value\", ...]

  Flags:
    -n | --name ..... enter custom Project name
    -a | --author ... enter custom Author
    -b | --bin ...... enter custom Binary Filename

  Imporant:
    When using multiple word value use quotation marks.
  
  To always use custom values create:
    ~/.config/CreateMakeFiles/CreateMakeFiles.conf

    - the first line MUST contain 'config=true'

  Config syntax:
    ProjectName=<custom-project-name> #Set ProjectName (Yes, comments work.)
    Author=<custom-author>
    BinFilename=<custom-bin-filename>
"

if [[ $# = 0 ]]; then # 0 ARGS
  echo -e "$HelpMenu"
  exit
fi

# 1 ARG

if [[ $1 = "-h" ]]; then # -h
  echo -e "$HelpMenu"
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

if ! [ -z config ]; then
  echo "Config was found..."
fi

while [[ $# > 0 ]]; do # 2+ ARGS
  shift                # Extension is not $1. Working with other flags
  case "$1" in
  "-n" | "--name")
    ProjectName=$2
    echo "Project name: $ProjectName"
    ;;
  "-a" | "--author")
    Author=$2
    echo "Author: $Author"
    ;;
  "-b" | "--bin")
    BinFilename=$2
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
