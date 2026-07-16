#!/bin/bash

set -ouex pipefail
FEDORA_VERSION=$(rpm -E %fedora)

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf
echo "install_weak_deps=False" >> /etc/dnf/dnf.conf

# Patch os-release so dnf5 copr uses fedora-${FEDORA_VERSION}-x86_64 chroots
sed -i 's/^ID=.*/ID=fedora/' /usr/lib/os-release /etc/os-release 2>/dev/null || true

# Disable DKMS post-install systemd hook globally — systemd is not running in containers
mkdir -p /etc/dkms && echo 'POST_INSTALL=""' >> /etc/dkms/framework.conf

## Enable repos
dnf5 -y install dnf5-plugins
dnf5 -y copr enable bieszczaders/kernel-cachyos fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable faugus/faugus-launcher fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable ilyaz/LACT fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable garecrow/ExtensionManager fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable wehagy/protonplus fedora-${FEDORA_VERSION}-x86_64
# Controller Xbox via Bluetooth → xpadneo dal COPR atim (ha il chroot F44).
# NB: sentry/xone rimosso: non ha più chroot F44 e serviva solo per il
# dongle wireless USB, che non usiamo.
dnf5 -y copr enable atim/xpadneo fedora-${FEDORA_VERSION}-x86_64
dnf5 -y copr enable ublue-os/akmods fedora-${FEDORA_VERSION}-x86_64
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

# Install CachyOS kernel pinned to 7.0.12
dnf5 -y --setopt=tsflags=noscripts install \
    kernel-cachyos \
    kernel-cachyos-devel-matched

dnf5 -y swap ffmpeg ffmpeg-free --allowerasing

dnf5 -y install --disablerepo=terra-mesa mesa-filesystem.i686 mesa-dri-drivers.i686 mesa-vulkan-drivers.i686 mesa-libEGL.i686 mesa-libGL.i686
dnf5 -y install intel-media-driver
dnf5 -y upgrade --best 'mesa-*'

# Determine installed kernel version
QUALIFIED_KERNEL=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-cachyos)

dnf5 -y install thunar thunar-volman thunar-archive-plugin   

# Install packages
dnf5 -y install \
ananicy-cpp \
cachyos-ananicy-rules \
cachyos-settings \
bore-sysctl \
scx-scheds \
scx-tools \
scx-manager \
gamemode \
gamemode.i686 \
power-profiles-daemon \
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
gnome-disk-utility \
gparted \
xhost \
mokutil \
lm_sensors \
sqlite3 \
openssl \
xdg-user-dirs \
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
kitty \
fish \
cascadia-code-nf-fonts \
libvirt \
virt-manager \
qemu-kvm \
flatpak-builder \
pciutils \
wlr-randr \
iotop \
sysstat \
lxqt-openssh-askpass \
mate-polkit \
parallel \
just \
seahorse \
file-roller \
unrar \
p7zip \
p7zip-plugins \
mpv \
loupe \
cosmic-store

# nwg-look
dnf5 -y copr enable tofik/nwg-shell
dnf5 -y install nwg-look adw-gtk3-theme --skip-unavailable

# Brave browser
mkdir -p /var/opt
dnf5 -y install dnf-plugins-core
dnf5 config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 -y install brave-origin

# VSCodium (RPM ufficiale, non flatpak)
rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
cat > /etc/yum.repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=download.vscodium.com
baseurl=https://download.vscodium.com/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF
dnf5 -y install codium

# Niri
dnf5 -y install niri


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

# Pre-select Niri as default session in dms-greeter
mkdir -p /var/cache/dms-greeter/.local/state
cat > /var/cache/dms-greeter/.local/state/memory.json << 'EOF'
{
    "lastSessionId": "/usr/share/wayland-sessions/niri.desktop"
}
EOF

mkdir -p /etc/skel/.config
rsync -aP /ctx/dot_config/. /etc/skel/.config/
mkdir -p /etc/skel/.local/state
cp -rPf /ctx/dot_config/DankMaterialShell /etc/skel/.local/state/

# Codec video
dnf5 -y install ffmpeg x264-libs libva-utils --allowerasing

# OBS
dnf5 -y install obs-studio obs-studio-plugin-x264

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

# Enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Container policy
echo '{"default":[{"type":"insecureAcceptAnything"}]}' > /etc/containers/policy.json

# Disable services
systemctl disable flatpak-add-fedora-repos.service
systemctl mask akmods-keygen@akmods-keygen.service
systemctl mask systemd-remount-fs.service

# Enable user service for first-run setup (creates XDG dirs, etc.)
mkdir -p /usr/lib/systemd/user/default.target.wants
ln -sf /usr/lib/systemd/user/veloxos-user.service /usr/lib/systemd/user/default.target.wants/veloxos-user.service

# Enable skel→home sync: propaga i dotfile di default aggiornati alle home
# esistenti dopo un `bootc upgrade` (skel di norma vale solo alla creazione utente).
ln -sf /usr/lib/systemd/user/veloxos-skel-sync.service /usr/lib/systemd/user/default.target.wants/veloxos-skel-sync.service

# Enable services
systemctl enable \
gpu-detect.service \
fix-dkms.service \
flatpak-cleanup.timer \
flatpak-repair.timer \
rpm-ostree-clean-metadata.timer \
rpm-ostree-clean-deployments.timer \
podman-prune.timer \
scx_loader.service \
power-profiles-daemon.service \
NetworkManager \
wpa_supplicant

dnf5 -y install xdg-desktop-portal-wlr xdg-desktop-portal-gtk

# Remove unwanted packages
dnf5 -y remove \
firefox* \
gdm \
gnome-shell \
gnome-shell-common \
gnome-shell-extension-common \
gnome-shell-extension-user-theme \
gnome-session \
gnome-session-wayland-session \
gnome-session-xsession \
gnome-control-center \
gnome-control-center-filesystem \
gnome-color-manager \
gnome-remote-desktop \
gnome-tour \
gnome-software \
pinentry-gnome3 \
gnome-srpm-macros \
xdg-desktop-portal-gnome \
nautilus \
totem \
eog \
gnome-maps \
gnome-weather \
gnome-clocks \
gnome-calculator \
gnome-calendar \
gnome-contacts \
gnome-photos \
gnome-text-editor \
gnome-system-monitor \
gnome-connections \
loupe \
snapshot \
papers \
decibels

# Remove waybar
dnf -y remove waybar

# Remove third-party repos — packages already installed, repos cause GPG errors at ISO build time
# Terra stays but disabled (not deleted): veloxos install --enablerepo=terra still needs it
# at runtime for opt-in packages (e.g. lsfg-vk) not installed during this build.
sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/terra*.repo
rm -f /etc/yum.repos.d/rpmfusion*.repo
rm -f /etc/yum.repos.d/google-chrome.repo
rm -f /etc/yum.repos.d/edge.repo
rm -f /etc/yum.repos.d/vscode.repo
rm -f /etc/yum.repos.d/vscodium.repo
# NB: i repo COPR restano abilitati qui perché nvidia.sh/drivers.sh installano
# ancora da essi (atim/xpadneo, ublue-os/akmods). Vengono disabilitati alla
# fine di tutto in post-build.sh.

# Clean up
dnf5 -y clean all
rm -rf /var/cache/dnf
