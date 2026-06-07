#!/bin/bash

set -ouex pipefail

# Determine the installed kernel version
QUALIFIED_KERNEL=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-cachyos)

# Install controller and power management drivers
# COPRs enabled in build.sh: sentry/xone, sentry/xpadneo, ublue-os/akmods
dnf5 install -y --setopt=tsflags=noscripts --skip-unavailable \
    xpadneo \
    xpad-noone \
    xone \
    lpf-xone-firmware \
    zenergy

# Build akmods (handles akmod-* packages if present)
mkdir -p /var/log/akmods
touch /var/log/akmods/akmods.log
KVER="$(dnf5 repoquery --installed --qf '%{VERSION}-%{RELEASE}.%{ARCH}' kernel-cachyos)"
akmods --force --kernels "$KVER" || true

# Build all DKMS-registered modules for the pinned kernel
dkms autoinstall -k "${QUALIFIED_KERNEL}" || \
    echo "Warning: some DKMS modules failed to build, continuing."

# Generate module dependencies
depmod "${QUALIFIED_KERNEL}"

# Generate initramfs for that kernel
/usr/bin/dracut --no-hostonly --kver "${QUALIFIED_KERNEL}" --reproducible --zstd -v \
    --add ostree --add fido2 -f "/usr/lib/modules/${QUALIFIED_KERNEL}/initramfs.img"

chmod 0600 /usr/lib/modules/"${QUALIFIED_KERNEL}"/initramfs.img
