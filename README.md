# GNUstep-docker

This repository contains an example of how to build a GNUstep application using Docker.

### Create Docker Image:

```
docker build -t gnustep --no-cache - < ./Dockerfile
```

### Run as a Container:

```
docker run -dit --env="DISPLAY=host.docker.internal:0" gnustep
```

### Hello world application location:

The hello world application will automatically launch, it is located at: 

```
/home/docker/GNUstep-hello-world
```

The hello world application can be compiled and run with:

```
cd /home/docker/GNUstep-hello-world
. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh
make
./Hello.app/Hello
```

## Install and run XQuartz to run X11 GUI apps on macOS

If you are running macOS, you can install XQuartz to run X11 GUI apps on your Mac.

```
brew install --cask xquartz
open -a XQuartz
```

Go to XQuarts > Security Settings, and ensure that "Allow connections from network clients" is on

Restart your Mac 

Start XQuartz again with: 

```
open -a XQuartz
```

Check if XQuartz is setup and running correctly

```
ps aux | grep Xquartz
```

Must show something similar to this: */opt/X11/bin/Xquartz :0 -listen tcp*

Then, allow X11 forwarding via xhost

```
xhost +localhost
```

Instructions from: [X11 forwarding on macOS and docker](https://gist.github.com/sorny/969fe55d85c9b0035b0109a31cbcb088)