FROM ubuntu:22.04

# Create Docker Image:
# docker build -t gnustep - < ./Dockerfile
# docker build -t gnustep --no-cache - < ./Dockerfile

# Run as a Container (ensure XQuartz is running):
# docker run -dit --env="DISPLAY=host.docker.internal:0" gnustep

# Install and run XQuartz to run X11 GUI apps on macOS
# https://gist.github.com/sorny/969fe55d85c9b0035b0109a31cbcb088
# brew install --cask xquartz
# open -a XQuartz
# > Go to Security Settings and ensure that "Allow connections from network clients" is on
# > Restart your Mac 
# > Start XQuartz again with: 
# open -a XQuartz
# > Ensure that XQuartz is running similar to this: /opt/X11/bin/Xquartz :0 -listen tcp
# > Allow X11 forwarding via xhost (unsafe all hosts: xhost +)
# xhost +localhost

# Set ARGs
ARG timeZone="America/New_York"
ARG userName=docker

ARG userFolder=/home/$userName
ARG pathSh=/usr/GNUstep/System/Library/Makefiles/GNUstep.sh
ARG pathApp=$userFolder/GNUstep-hello-world
ARG pathEntry=$pathApp/entry.sh

# Use /bin/bash instead of /bin/sh to activate "tab" autocompletion and "arrow keys" history
RUN ln -sf /bin/bash /bin/sh

# Update apt
RUN apt -y update

# Set sudo without password and add user
RUN apt-get -y install sudo
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
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

# Set user
USER docker

# Install GNUstep
WORKDIR $userFolder
RUN git clone https://github.com/plaurent/gnustep-build
WORKDIR $userFolder/gnustep-build/ubuntu-22.04-clang-14.0-runtime-2.1/
RUN ./GNUstep-buildon-ubuntu2204.sh

# Set environment variables
RUN . $pathSh && defaults write NSGlobalDomain GSSuppressAppIcon YES
RUN . $pathSh && defaults write NSGlobalDomain GSAppOwnsMiniwindow NO
RUN . $pathSh && defaults write NSGlobalDomain NSMenuInterfaceStyle NSWindows95InterfaceStyle
RUN . $pathSh && defaults read NSGlobalDomain

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
ENTRYPOINT ["/home/docker/GNUstep-hello-world/entry.sh"]
