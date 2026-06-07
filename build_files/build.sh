#!/bin/bash

set -ouex pipefail
FEDORA_VERSION=$(rpm -E %fedora)

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

# Patch os-release so dnf5 copr uses fedora-${FEDORA_VERSION}-x86_64 chroots
sed -i 's/^ID=.*/ID=fedora/' /usr/lib/os-release /etc/os-release 2>/dev/null || true

## Enable repos
dnf5 -y install dnf5-plugins
dnf5 -y copr enable bieszczaders/kernel-cachyos fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable faugus/faugus-launcher fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable ilyaz/LACT fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable garecrow/ExtensionManager fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable wehagy/protonplus fedora-${FEDORA_VERSION}-x86_64
dnf5 -y install \
https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm \
https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm

dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
rpm --import https://repos.fyralabs.com/terra${FEDORA_VERSION}/key.asc
rpm --import https://repos.fyralabs.com/terra${FEDORA_VERSION}-mesa/key.asc
rpm --import https://repos.fyralabs.com/terra${FEDORA_VERSION}-multimedia/key.asc
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 -y install --nogpgcheck --repofrompath 'terra-mesa,https://repos.fyralabs.com/terra$releasever' terra-release-mesa
dnf5 -y install --nogpgcheck --repofrompath 'terra-multimedia,https://repos.fyralabs.com/terra$releasever' terra-release-multimedia
sed -i '/^priority=/d' /etc/yum.repos.d/terra*.repo

# Download Terra AppStream data
TERRA_BASE="https://repos.fyralabs.com/appstream"
TERRA_REPOS="terra${FEDORA_VERSION} terra${FEDORA_VERSION}-mesa terra${FEDORA_VERSION}-nvidia terra${FEDORA_VERSION}-extras terra${FEDORA_VERSION}-multimedia"
mkdir -p /usr/share/swcatalog/xml
for REPO in $TERRA_REPOS; do
    BASE_URL="${TERRA_BASE}/${REPO}/latest/appstream"
    curl -fsSL "${BASE_URL}/${REPO}.xml.gz" -o "/usr/share/swcatalog/xml/${REPO}.xml.gz" \
        && echo "Terra AppStream: ${REPO}.xml.gz" || echo "Warning: failed to download AppStream for ${REPO}"
    mkdir -p "/usr/share/swcatalog/icons/${REPO}/64x64"
    mkdir -p "/usr/share/swcatalog/icons/${REPO}/128x128"
    curl -fsSL "${BASE_URL}/${REPO}-icons-64x64.tar.gz" \
        | tar -xz -C "/usr/share/swcatalog/icons/${REPO}/64x64" --strip-components=1 2>/dev/null || true
    curl -fsSL "${BASE_URL}/${REPO}-icons-128x128.tar.gz" \
        | tar -xz -C "/usr/share/swcatalog/icons/${REPO}/128x128" --strip-components=1 2>/dev/null || true
done

# Enable Chrome repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/google-chrome.repo

# Remove Fedora kernel and zram config
dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs zram-generator-defaults

# Install CachyOS kernel pinned to 7.0.11
dnf5 -y --setopt=tsflags=noscripts install \
    "kernel-cachyos-7.0.11*" \
    "kernel-cachyos-devel-matched-7.0.11*"

dnf5 -y swap ffmpeg ffmpeg-free --allowerasing

dnf5 -y install mesa-dri-drivers.i686 mesa-va-drivers.i686 mesa-vulkan-drivers.i686 mesa-libEGL.i686 mesa-libGL.i686
dnf5 -y upgrade --best 'mesa-*'

# Determine installed kernel version
QUALIFIED_KERNEL=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-cachyos)

# Install packages
dnf5 -y install \
ananicy-cpp \
cachyos-ananicy-rules \
cachyos-settings \
bore-sysctl \
scx-scheds \
scx-tools \
gamemode \
gamemode.i686 \
pulseaudio-utils \
dkms \
akmods \
kernel-cachyos-devel-${QUALIFIED_KERNEL} \
elfutils-libelf-devel \
openssl-devel \
git \
flatpak \
libxcrypt-compat \
rsync \
podman \
distrobox \
mokutil \
lm_sensors \
sqlite3 \
openssl \
libnotify \
inotify-tools \
podman-compose \
python3-pip \
python3-setuptools \
appstream \
appstream-data \
fwupd \
fuse \
squashfuse \
v4l-utils \
unzip \
alacritty \
libvirt \
virt-manager \
qemu-kvm \
flatpak-builder \
wlr-randr \
iotop \
sysstat \
lxqt-openssh-askpass \
lxpolkit \
parallel \
just \
seahorse \
nautilus \
mpv \
cosmic-store

# Remove unwanted packages
dnf5 -y remove firefox* nss

# nwg-look
dnf5 -y copr enable tofik/nwg-shell
dnf5 -y install nwg-look adw-gtk3-theme yaru-theme --skip-unavailable

# Brave browser
mkdir -p /var/opt
dnf5 config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 -y install brave-browser

# Niri
dnf5 -y install niri

# Bibata cursor
curl -Lo /tmp/bibata.tar.xz https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Classic.tar.xz
tar -xf /tmp/bibata.tar.xz -C /usr/share/icons/
rm /tmp/bibata.tar.xz

# DMS shell
curl --output-dir "/etc/yum.repos.d/" \
  --remote-name "https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-${FEDORA_VERSION}/avengemedia-dms-fedora-${FEDORA_VERSION}.repo"
dnf5 -y install quickshell dms greetd dms-greeter --allowerasing

# Greetd config
mkdir -p /etc/greetd/
cat > /etc/greetd/config.toml << EOF
[terminal]
vt = 1
[default_session]
user = "greeter"
command = "dms-greeter --command niri"
EOF
rm -f /etc/systemd/system/display-manager.service
ln -s /usr/lib/systemd/system/greetd.service /etc/systemd/system/display-manager.service
systemctl enable --force greetd.service

mkdir -p /etc/skel/.config/systemd/user/graphical-session.target.wants
ln -s /usr/lib/systemd/user/dms.service /etc/skel/.config/systemd/user/graphical-session.target.wants/
mkdir -p /etc/skel/.config/niri/
cp -rf /ctx/dot_config/niri/config.kdl /etc/skel/.config/niri/

# Codec video
dnf5 -y install ffmpeg x264-libs libva-utils --allowerasing

# OBS
dnf5 -y install obs-studio obs-studio-plugin-x264

# Enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Container policy
echo '{"default":[{"type":"insecureAcceptAnything"}]}' > /etc/containers/policy.json

# Disable services
systemctl disable flatpak-add-fedora-repos.service
systemctl mask akmods-keygen@akmods-keygen.service
systemctl mask systemd-remount-fs.service

# Enable services
systemctl enable \
fix-dkms.service \
flatpak-cleanup.timer \
flatpak-repair.timer \
rpm-ostree-clean-metadata.timer \
rpm-ostree-clean-deployments.timer \
podman-prune.timer \
NetworkManager \
wpa_supplicant

# Clean up
dnf5 -y clean all
rm -rf /var/cache/dnf
