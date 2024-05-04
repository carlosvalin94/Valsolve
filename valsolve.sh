#!/bin/bash

clear

echo "¿Would you like to proceed with the installation of Davinci Resolve? (y/n)"
read answer

if [ "$answer" != "y" ]; then
    echo "Installation cancelled."
    exit 1
fi

echo "Please select your GPU: "
echo "1. Nvidia"
echo "2. AMD"
read -p "Option: " gpu

# Add user to render group
sudo usermod -aG render $(whoami)

# Add folder for launcher
sudo mkdir /opt/resolve/

# Install Distrobox
sudo apt install -y distrobox
sudo dnf install -y distrobox
sudo pacman -S -y distrobox
sudo zypper install -y distrobox
rpm-ostree install distrobox

# Create Distrobox and install dependencies
distrobox-create --name Resolve-Fedora-37 --image fedora:37 --pull
clear

alias distent='distrobox enter Resolve-Fedora-37 -e'

distent sudo dnf install -y alsa-plugins-pulseaudio libxcrypt-compat xcb-util-renderutil xcb-util-wm pulseaudio-libs xcb-util xcb-util-image xcb-util-keysyms libxkbcommon-x11 libXrandr libXtst mesa-libGLU mtdev libSM libXcursor libXi libXinerama libxkbcommon libglvnd-egl libglvnd-glx libglvnd-opengl libICE librsvg2 libSM libX11 libXcursor libXext libXfixes libXi libXinerama libxkbcommon libxkbcommon-x11 libXrandr libXrender libXtst libXxf86vm mesa-libGLU mtdev pulseaudio-libs xcb-util alsa-lib apr apr-util fontconfig freetype libglvnd fuse-libs xcb-util-cursor

# Check GPU and Install OpenCL for AMD GPU or Nvidia drivers for Nvidia GPU
if [ $gpu -eq 1 ]; then
    distent sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    
elif [ $gpu -eq 2 ]; then
    distent sudo dnf install -y rocm-opencl
else
    echo "GPU not supported"
fi

filename="DaVinci_*.run"

if [ ! -f $filename ]; then
clear
    echo "The installer was not found. Please enter the name"
    read user_input
    if [ -f "$user_input" ]; then
        distent sudo ./$user_input -i
    else
        echo "The specified file does not exist"
        exit 1
    fi
else
    distent sudo ./$filename -i
fi

distent distrobox-export --app /opt/resolve/bin/resolve

clear

echo "Davinci Resolve installation completed"
