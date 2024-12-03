#!/bin/bash

echo "Removing /usr/bin/CreateMakeFile..."
echo ""

sudo rm /usr/local/bin/CreateMakeFile

if [ -f "/usr/bin/CreateMakeFile" ]; then
  echo "Uninstallation failed, file still exists."
  echo "Aborting"
  exit
fi

echo "Installation succesful"
