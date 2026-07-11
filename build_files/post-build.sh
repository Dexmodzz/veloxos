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
scx-manager
gamemode
gamemode.i686
power-profiles-daemon
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
gnome-disk-utility
gparted
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
solaar
solaar-udev
fish
cascadia-code-nf-fonts
python3-pip
python3-setuptools
appstream
appstream-data
fwupd
ffmpeg
kitty
libvirt
virt-manager
qemu-kvm
flatpak-builder
wlr-randr
iotop
sysstat
lxqt-openssh-askpass
mate-polkit
parallel
just
seahorse
thunar
mpv
loupe
cosmic-store
codium
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

# Hide unwanted .desktop entries from launcher
rm -f \
    /usr/share/applications/thunar-settings.desktop \
    /usr/share/applications/thunar-bulk-rename.desktop \
    /usr/share/applications/gnome-panel.desktop \
    /usr/share/applications/panel-preferences.desktop \
    /usr/share/applications/panel-desktop-handler.desktop \
    /usr/share/applications/org.gnome.ColorProfileViewer.desktop \
    /usr/share/applications/lpf.desktop \
    /usr/share/applications/lpf-gui.desktop \
    /usr/share/applications/lpf-notify.desktop \
    /usr/share/applications/lpf-xone-firmware.desktop \
    /usr/share/applications/org.freedesktop.MalcontentControl.desktop \
    /usr/share/applications/org.gnome.Tour.desktop \
    /usr/share/applications/rygel-preferences.desktop

update-desktop-database /usr/share/applications

# Disabilita tutti i repo COPR nell'immagine finale (gira per ultimo, dopo che
# nvidia.sh/drivers.sh hanno finito di installare). I pacchetti sono già dentro
# l'immagine e bootc aggiorna via immagine, non via questi repo: lasciarli
# abilitati fa fallire bootc-image-builder / dnf quando un COPR perde il chroot
# della Fedora corrente (es. sentry/xone su F44 → repomd.xml 404).
sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/_copr*.repo 2>/dev/null || true

# Brand as VeloxOS — keep ID=fedora for tool compatibility (bootc-image-builder, dnf copr, etc.)
sed -i 's/^NAME=.*/NAME=VeloxOS/' /usr/lib/os-release /etc/os-release 2>/dev/null || true
sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="VeloxOS"/' /usr/lib/os-release /etc/os-release 2>/dev/null || true
