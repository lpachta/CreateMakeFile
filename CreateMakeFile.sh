#!/bin/bash

BOLD="\033[1m"
RESET="\033[0m"

HelpMenu="
  
  ╭───────────────────────────────╮
  │   --== ${BOLD}CreateMakeFiles${RESET} ==--   │
  ╰───────────────────────────────╯

  CreateMakeFiles is a bash script used for automatic creating of a Makefile.

  Supported languages: C, C++
  
  This info:
    CreateMakeFiles -h

  Usage:
    CreateMakeFile <c | cpp> [--flag \"value\", ...]

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
if [[ -z $ProjectName ]]; then # Set default ProjectName
  ProjectName=$(basename "$(pwd)")
fi

if [[ -z $Author ]]; then # Set default Author
  Author=$(whoami)
  echo "Author: $Author"
fi

if [[ -z $C_ext ]]; then # Set default C bin Extension
  C_ext=".bin"
fi
if [[ -z $Cpp_ext ]]; then # Set default Cpp bin Extension
  Cpp_ext=".bin"
fi
if [[ -z $Java_ext ]]; then # Set default Java bin Extension
  Java_ext=".class"
fi
if [[ -z $C_header_ext ]]; then
  C_header_ext=".h"
fi

if [[ -z $BinFilename ]]; then # Set default Bin Filename
  case "$Extension" in
  "c")
    BinFilename="\$(NAME)$C_ext"
    ;;
  "cpp")
    BinFilename="\$(NAME)$Cpp_ext"
    ;;
  "java")
    BinFilename="Main"
    ;;
  *)
    echo "Extension $Extension is not supported."
    echo "Aborting."
    ;;
  esac
fi

case "$Extension" in # Default Compilation stuff //TODO: like, make it clean in here TODO: Also make all stuff changable in the config
"c")
  CC="gcc"
  CFlags="-std=c99 -pedantic -Wall -g"
  Compile="\$(CC) \$(CFLAGS) \$(SRCS) -o \$(BIN)"
  Run="./\$(BIN)"
  ;;
"cpp")
  CC="g++"
  CFlags="-g -std=c++14 -Wall -Werror -pedantic"
  Compile="\$(CC) \$(CFLAGS) \$(SRCS) -o \$(BIN)"
  Run="./\$(BIN)"
  ;;
"java")
  CC="javac"
  Compile="\$(CC) \$(SRCS)"
  Run="java Main"
  ;;
*)
  echo "ERROR: unsupported extension!"
  exit
  ;;
esac
# End of defaults

# All info we need from the user is: ProjectName, Author, BinFilename, Extension
# Cannot run with no flag
# With one flag it's -h or extension without flag
# With more flags 1. Load the config 2. load the vars with from flags 3. Defaults

# Load files
for i in *.$Extension; do # Nacteni source files do array
  [ -f "$i" ] || break
  SourceFiles+=("$i")
done
if [[ ${#SourceFiles[@]} == 0 ]]; then # If no source files are found
  echo "ERROR: No files in $pwd with extension .$Extension"
  echo "Aborting"
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
#
# TODO: In Run add prerequizitiez. Make a var with the file that is outputted by the compiler and a var with name of the file that is run

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
