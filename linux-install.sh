#!/bin/bash

echo ""
if ! [ -f "./CreateMakeFile.sh" ]; then
  echo "CreateMakeFile.sh is missing! Aborting..."
  echo ""
  exit
fi

chmod +x ./CreateMakeFile.sh
echo "CreateMakeFile.sh has been made executable..."
echo ""

echo "Copying CreateMakeFile.sh to /usr/bin/CreateMakeFile..."
sudo cp ./CreateMakeFile.sh /usr/local/bin/CreateMakeFile
echo ""

if [ -f "/usr/local/bin/CreateMakeFile" ]; then
  echo "Installation succesfully complete."
  echo ""
else
  echo "Installation error: Copying failed"
  echo "Aborting ..."
  echo ""
  exit
fi

while [[ true ]]; do

  read -p "Do you wish to make a configuration file? [Y/n]" choice
  case "$choice" in
  [Nn] | [Nn][Oo])
    if [ -f ~/.config/CreateMakeFiles/CreateMakeFiles.conf ]; then
      echo "Config wasn't created, but older one was found"
    fi
    exit
    ;;
  [Yy] | [Yy][Ee][Ss] | "")
    cp ./CreateMakeFile.conf ~/.config/CreateMakeFiles/CreateMakeFiles.conf
    if [ -f ~/.config/CreateMakeFiles/CreateMakeFiles.conf ]; then
      echo "Config has been succesfully created."
    fi
    exit
    ;;
  *)
    echo "Invalid input..."
    ;;
  esac
done
