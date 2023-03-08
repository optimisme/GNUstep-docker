FROM ubuntu:22.04

# Set ARGs
ARG timeZone="America/New_York"
ARG userName=docker

ARG userFolder=/home/$userName
ARG pathSh=/usr/GNUstep/System/Library/Makefiles/GNUstep.sh
ARG pathApp=$userFolder/GNUstep-hello-world
ARG execApp=./Hello.app/Hello
ARG pathEntry=$pathApp/runApp.sh

# Use /bin/bash instead of /bin/sh 
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
ENV ENV ~/.profile

# Update apt listings
RUN apt -y update

# Set sudo without password and add user
RUN apt-get -y install sudo
RUN useradd -m $userName && echo "$userName:$userName" | chpasswd && adduser $userName sudo
RUN chown -R "$userName:$userName" "$userFolder"
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set timeZone
RUN apt -y install tzdata -y
ENV TZ=$timeZone

# Install x11-apps
RUN apt-get install -y --no-install-recommends x11-apps

# Install dependencies
RUN apt -y install git
RUN apt -y install build-essential
RUN apt -y install clang
RUN apt -y install libgl-dev
RUN apt -y install libglu1-mesa-dev

# Install additionals
RUN apt -y install fonts-open-sans

# Set user
USER $userName

# Install GNUstep
WORKDIR $userFolder
RUN git clone https://github.com/plaurent/gnustep-build
WORKDIR $userFolder/gnustep-build/ubuntu-22.04-clang-14.0-runtime-2.1/
RUN ./GNUstep-buildon-ubuntu2204.sh

# Set environment variables
RUN . $pathSh && defaults write NSGlobalDomain GSSuppressAppIcon YES
RUN . $pathSh && defaults write NSGlobalDomain GSAppOwnsMiniwindow NO
RUN . $pathSh && defaults write NSGlobalDomain NSMenuInterfaceStyle NSWindows95InterfaceStyle

RUN . $pathSh && defaults write NSGlobalDomain GSTheme WinClassic

RUN . $pathSh && defaults write NSGlobalDomain NSFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSBoldFont OpenSans-Bold
RUN . $pathSh && defaults write NSGlobalDomain NSBoldFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSLabelFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSLabelFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSMenuFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSMenuFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSMessageFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSMessageFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSPaletteFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSPaletteFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSTitleBarFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSTitleBarFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSToolTipsFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSToolTipsFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSControlContentFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSControlContentFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSUserFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSUserFontSize 14.0
RUN . $pathSh && defaults write NSGlobalDomain NSUserFixedPitchFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSUserFixedPitchFontSize 14.0

# Install GNUstep system preferences
WORKDIR $userFolder
RUN cd $userFolder && git clone https://github.com/gnustep/apps-systempreferences
WORKDIR $userFolder/apps-systempreferences
RUN sudo -- bash -c ". $pathSh && make && make install"

# Add GNUstep themes
WORKDIR $userFolder
ENV pathThemes=GNUstep/Library/Themes
ENV gitThemes=https://github.com/gnustep/themes.git
RUN cd $userFolder && mkdir -p GNUstep && mkdir -p GNUStep/Library && mkdir -p $pathThemes
RUN cd $userFolder/$pathThemes && git clone $gitThemes && cd themes && mv * ../ && rm -rf themes

# Install GNUstep-hello-world
WORKDIR $userFolder
RUN git clone https://github.com/optimisme/GNUstep-hello-world.git
RUN cd $pathApp && . $pathSh && make

# Create an entrypoint
RUN echo "#!/bin/bash" > $pathEntry
RUN echo "cd $pathApp" >> $pathEntry
RUN echo ". $pathSh" >> $pathEntry
RUN echo "$execApp" >> $pathEntry
RUN chmod +x $pathEntry

# Set entrypoint (can't use ARGs)
ENTRYPOINT ["/home/docker/GNUstep-hello-world/runApp.sh"]
