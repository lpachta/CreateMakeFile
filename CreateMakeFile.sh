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

. ~/.config/CreateMakeFiles/CreateMakeFiles.conf # Load a config

# Check if config was loaded
if ! [ -z config ]; then
  echo "Config was found..."
fi

# Load other args
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

# Set Defaults Not if not overwritten by config
# General vars
if [[ -z $Author ]]; then # Set default Author
  Author=$(whoami)
  echo "Author: $Author"
fi
if [[ -z $ProjectName ]]; then # Set default ProjectName
  ProjectName=$(basename "$(pwd)")
  echo "Project name: $ProjectName"
fi
if [[ -z $date ]]; then
  date="$(date)"
  echo "Date: $date"
fi

# Language specific vars
case "$Extension" in
"c")
  if [[ -z $C_binExt ]]; then # Set default C bin Extension
    C_binExt=".bin"
  fi
  if [[ -z $BinFilename ]]; then
    BinFilename="\$(NAME)$C_binExt"
    echo "Binary file: $BinFilename"
  fi
  if [[ -z $CC ]]; then
    CC="gcc"
    echo "Compiler: $CC"
  fi
  if [[ -z CFlags ]]; then
    CFlags="-std=c99 -pedantic -Wall -g"
  fi
  if [[ -z $Compile ]]; then
    Compile="\$(CC) \$(CFLAGS) \$(SRCS) -o \$(BIN)"
  fi
  if [[ -z $Run ]]; then
    Run="./\$(BIN)"
  fi
  ;;
"cpp")
  if [[ -z $Cpp_binExt ]]; then # Set default Cpp bin Extension
    Cpp_binExt=".bin"
  fi
  if [[ -z $BinFilename ]]; then
    BinFilename="\$(NAME)$Cpp_binExt"
    echo "Binary file: $BinFilename"
  fi
  if [[ -z $CC ]]; then
    CC="g++"
    echo "$CC"
  fi
  if [[ -z CFlags ]]; then
    CFlags="-g -std=c++14 -Wall -Werror -pedantic"
  fi
  if [[ -z $Compile ]]; then
    Compile="\$(CC) \$(CFLAGS) \$(SRCS) -o \$(BIN)"
  fi
  if [[ -z $Run ]]; then
    Run="./\$(BIN)"
  fi
  ;;
"java")
  if [[ -z $Java_binExt ]]; then # Set default Java bin Extension
    Java_binExt=".class"
  fi
  if [[ -z $BinFilename ]]; then
    BinFilename="Main$Java_binExt"
  fi
  if [[ -z $CC ]]; then
    CC="javac"
  fi
  if [[ -z $Compile ]]; then
    Compile="\$(CC) \$(SRCS)"
  fi
  if [[ -z $Run ]]; then
    Run="java \$(basename \$(BIN))"
  fi
  ;;
*)
  echo "ERROR: Extension $Extension is not supported..."
  echo "Aborting."
  ;;
esac
# End of defaults

# Load files
for i in *.$Extension; do # Nacteni source files do array
  [ -f "$i" ] || break
  SourceFiles+=("$i")
done
if [[ ${#SourceFiles[@]} == 0 ]]; then # If no source files are found
  echo "ERROR: No files in $pwd with extension .$Extension..."
  echo "Aborting."
  exit
fi
echo "Found Source files: ${SourceFiles[*]}"

# Load header files if c/cpp
case "$Extension" in
"c" | "cpp")
  for j in *.h; do # Nacteni header files do array
    [ -f "$j" ] || break
    HeaderFiles+=("$j")
  done
  echo "Found Header files: ${HeaderFiles[*]}"
  ;;
*) ;;
esac
# End of Loading files

# TODO: In Run add prerequisities. Make a var with the file that is outputted by the compiler and a var with name of the file that is run

echo "# Projekt: $ProjectName
# Autor: $Author

# Project name
NAME = $ProjectName

# Binary filename (also target)
BIN = $BinFilename
# Source files
SRCS = ${SourceFiles[*]}
# Modules 
MODULES = ${HeaderFiles[*]}
# Files that are put into archives
ARCHIVE_FILES = \$(SRCS) \$(MODULES) Makefile # Feel free to add additional files here

# Zip filename
ZIP=\$(NAME).zip
# Tar filename
TAR=\$(NAME).tar.gz

# Compiler
CC = $CC
# Compile flags
CFLAGS = $CFlags

# Compilation command
COMPILATION=$Compile

# Compile and run 
.PHONY: compileAndRun
compileAndRun: \$(SRCS)
		\$(COMPILATION)
		$Run

# Run the target
.PHONY: run
run: 
		$Run

.PHONY: compile 
compile: \$(BIN)

# Compile target
\$(BIN): \$(SRCS)
		\$(COMPILATION)

# Archive files into zip
.PHONY:
zip:
		zip \$(ZIP) \$(ARCHIVE_FILES)

# Archive files into tar.gz
.PHONY:
tar: 
		tar -czvf \$(TAR) \$(ARCHIVE_FILES)

# Remove bin file
.PHONY: rm-bin 
rm-bin: \$(BIN)
		rm -f \$(BIN)

# Remove zip archive
.PHONY: rm-zip
rm-zip: zip
		rm \$(ZIP)

# Remove tar.gz archive
.PHONY: rm-tar
rm-tar: tar
		rm \$(TAR)

.PHONY: clean
clean: rm-tar rm-zip rm-bin
" >Makefile

if [ -f Makefile ]; then
  echo "Makefile has been created."
  exit
fi

echo "ERROR: Makefile has not been created."
