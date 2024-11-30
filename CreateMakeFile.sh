#!/bin/bash

help="
  // CreateMakeFiles // 
  
  Usage:
  CreateMakeFiles <extension>
  
  Supported languages: C
"

if [[ $1 == "-h" ]]; then
  echo "$help"
  exit
fi

if [[ $@ < 2 ]]; then
  echo "$help"
  exit
fi

Extension=$1

ProjectName=$(basename "$(pwd)") # TODO: moznost nacist jmeno projektu ze vstupu
Author=$(whoami)                 # TODO: moznost nacist jmeno autora z configu

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

EXE_FILE=\$(NAME).bin
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
