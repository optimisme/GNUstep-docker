FROM ubuntu:22.04

# Set ARGs
ARG timeZone="America/New_York"
ARG userName=docker

ARG userFolder=/home/$userName
ARG pathSh=/usr/GNUstep/System/Library/Makefiles/GNUstep.sh
ARG pathApp=$userFolder/GNUstep-hello-world
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

RUN . $pathSh && defaults write NSGlobalDomain NSFont OpenSans
RUN . $pathSh && defaults write NSGlobalDomain NSFontSize 14.0

# Install GNUstep system preferences
WORKDIR $userFolder
RUN cd $userFolder && git clone https://github.com/gnustep/apps-systempreferences
WORKDIR $userFolder/apps-systempreferences
RUN sudo -- bash -c ". $pathSh && make && make install"

# Install GNUstep-hello-world
WORKDIR $userFolder
RUN git clone https://github.com/optimisme/GNUstep-hello-world.git
RUN cd $pathApp && . $pathSh && make

# Create an entrypoint
RUN echo "#!/bin/bash" > $pathEntry
RUN echo "cd $pathApp" >> $pathEntry
RUN echo ". $pathSh" >> $pathEntry
RUN echo "./Hello.app/Hello" >> $pathEntry
RUN chmod +x $pathEntry

# Set entrypoint (can't use ARGs)
ENTRYPOINT ["/home/docker/GNUstep-hello-world/runApp.sh"]
