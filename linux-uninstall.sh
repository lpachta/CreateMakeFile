#!/bin/bash

echo "Removing /usr/bin/CreateMakeFile"
echo ""

sudo rm /usr/bin/CreateMakeFile

if [ -f "/usr/bin/CreateMakeFile" ]; then
  echo "Installation failed"
  echo "Aborting..."
  exit
fi

echo "Installation succesful"
