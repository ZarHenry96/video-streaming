#!/bin/bash

echo "Install the Python packages required by the visualization script"
sudo pip3 install -r setup/requirements.txt
sudo apt-get install -qy python3-pil.imagetk
