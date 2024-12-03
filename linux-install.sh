#!/bin/bash

echo "Copying CreateMakeFile.sh to /usr/bin/CreateMakeFile..."
echo ""
if ! [ -f "./CreateMakeFile.sh" ]; then
  echo "CreateMakeFile.sh is missing! Aborting..."
  echo ""
  exit
fi
chmod +x ./CreateMakeFile.sh
sudo cp ./CreateMakeFile.sh /usr/local/bin/CreateMakeFile
if [ -f "/usr/local/bin/CreateMakeFile" ]; then
  echo "Installation complete."
  echo ""
  exit
else
  echo "Installation error: Copying failed"
  echo "Aborting ..."
  echo ""
  exit
fi
