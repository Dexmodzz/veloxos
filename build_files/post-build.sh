#!/bin/bash

set -ouex pipefail

# Mark all base image packages as dependency so PackageKit only manages overlay packages
dnf5 -y mark dependency $(rpm -qa --qf '%{NAME} ') --skip-unavailable

echo "VeloxOS post-build complete."

# Build protected-packages.txt
PROTECTED_FILE="/usr/share/veloxos/protected-packages.txt"
mkdir -p /usr/share/veloxos

if [[ -f "$PROTECTED_FILE" ]]; then
    echo "nvidia build detected — appending base packages to existing protected-packages.txt..."
else
    echo "Normal build — creating protected-packages.txt with base packages..."
    > "$PROTECTED_FILE"
fi

cat >> "$PROTECTED_FILE" << 'EOF'

# Base image packages (veloxos/build_files/build.sh)
dnf5-plugins
dnf-plugins-core
kernel-cachyos
kernel-cachyos-devel-matched
ananicy-cpp
cachyos-ananicy-rules
cachyos-settings
bore-sysctl
scx-scheds
scx-tools
gamemode
gamemode.i686
pulseaudio-utils
dkms
akmods
mokutil
elfutils-libelf-devel
openssl-devel
git
flatpak
podman
distrobox
podman-compose
lm_sensors
v4l-utils
mesa-dri-drivers.i686
mesa-va-drivers.i686
mesa-vulkan-drivers.i686
mesa-libEGL.i686
mesa-libGL.i686
libxcrypt-compat
rsync
fuse
squashfuse
sqlite3
openssl
libnotify
inotify-tools
unzip
python3-pip
python3-setuptools
appstream
appstream-data
fwupd
ffmpeg
alacritty
libvirt
virt-manager
qemu-kvm
flatpak-builder
wlr-randr
iotop
sysstat
lxqt-openssh-askpass
lxpolkit
parallel
just
seahorse
nautilus
mpv
cosmic-store
nwg-look
adw-gtk3-theme
brave-browser
niri
quickshell
dms
greetd
dms-greeter
obs-studio
x264-libs
libva-utils
EOF

echo "protected-packages.txt ready ($(grep -c '^[^#]' "$PROTECTED_FILE") packages)."

# Brand as VeloxOS — keep ID=fedora for tool compatibility (bootc-image-builder, dnf copr, etc.)
sed -i 's/^NAME=.*/NAME=VeloxOS/' /usr/lib/os-release /etc/os-release 2>/dev/null || true
sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="VeloxOS"/' /usr/lib/os-release /etc/os-release 2>/dev/null || true
