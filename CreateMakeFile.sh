#!/bin/bash

help="
  // CreateMakeFiles // 
  
  Usage:
  CreateMakeFiles <extension> [<project name>] [<binary filename>]
  
  Supported languages: C, C++, Java

  To use custom values:
    - create '~/.config/CreateMakeFiles/CreateMakeFiles.conf' 
      - Author=\"<author name>\"
      - bin=\"<bin filename>\"
"

if [[ $1 == "-h" ]]; then
  echo "$help"
  exit
fi

if [[ $# < 1 ]]; then
  echo "$help"
  exit
fi
Extension=$1

. ~/.config/CreateMakeFiles/CreateMakeFiles.conf # Include a config

if [[ $# > 1 ]]; then
  ProjectName=$2
else
  ProjectName=$(basename "$(pwd)")
fi

if [[ $# > 2 ]]; then
  bin=$3
else
  if [ -z "$bin" ]; then
    bin="\$(name).bin"
  fi
fi

if [ -z "$Author" ]; then
  Author=$(whoami)
fi

for i in *.$Extension; do # Nacteni source files do array
  [ -f "$i" ] || break
  SourceFiles+=("$i")
done

if [[ ${#SourceFiles[@]} == 0 ]]; then
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
  echo "unsupported extension!"
  exit
  ;;
esac

echo "# Projekt: $ProjectName
# Autor: $Author

# VARS
NAME=$ProjectName
SOURCE_FILES=${SourceFiles[*]}
CC=$CC

EXE_FILE=$bin 
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
