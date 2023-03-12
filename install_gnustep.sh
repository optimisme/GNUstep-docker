#!/bin/bash

userFolder=~/
pathOpen=/usr/GNUstep/System/Tools/openapp
pathShFolder=/usr/GNUstep/System/Library/Makefiles
pathSh=$pathShFolder/GNUstep.sh
pathApp=$userFolder/GNUstep-hello-world
execApp=$pathApp/Hello.app

# Update apt listings
sudo apt -y update

# Install dependencies
sudo apt -y install git
sudo apt -y install build-essential
sudo apt -y install clang
sudo apt -y install libgl-dev
sudo apt -y install libglu1-mesa-dev

# Install additionals
sudo apt -y install fonts-open-sans

# Install GNUstep
cd $userFolder
git clone https://github.com/plaurent/gnustep-build
cd $userFolder/gnustep-build/ubuntu-22.04-clang-14.0-runtime-2.1/
./GNUstep-buildon-ubuntu2204.sh

# Set environment variables
. $pathSh
defaults write NSGlobalDomain GSSuppressAppIcon YES
defaults write NSGlobalDomain GSAppOwnsMiniwindow NO
defaults write NSGlobalDomain NSMenuInterfaceStyle NSWindows95InterfaceStyle
defaults write NSGlobalDomain NSInterfaceStyleDefault NSWindows95InterfaceStyle

defaults write NSGlobalDomain GSTheme WinClassic

# Install GNUstep system preferences
cd $userFolder
git clone https://github.com/gnustep/apps-systempreferences
cd $userFolder/apps-systempreferences
sudo -- bash -c ". $pathSh && make && make install"

# Add GNUstep themes
cd $userFolder
export pathThemes=GNUstep/Library/Themes
export gitThemes=https://github.com/gnustep/themes.git
cd $userFolder && mkdir -p $pathThemes
cd $userFolder/$pathThemes && git clone $gitThemes && mv themes/* ./ && rm -rf themes

# Install GNUstep-hello-world
cd $userFolder
git clone https://github.com/optimisme/GNUstep-hello-world.git
cd $pathApp && . $pathSh && make

# Create an entrypoint
echo "export GNUSTEP_CONFIG_FILE=$pathShFolder" >> $userFolder/.bashrc