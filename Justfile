image_name     := "veloxos"
image_registry := "ghcr.io/dexmodzz"
default_tag    := "latest"

# Build an ISO locally from an OCI image
# Usage: just build-iso [image] [tag]
# Example: just build-iso ghcr.io/dexmodzz/veloxos latest
build-iso image=image_registry+"/"+image_name tag=default_tag:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p output
    sudo podman run \
        --rm \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v "$(pwd)/output:/output" \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        ghcr.io/osbuild/bootc-image-builder:latest \
        --type iso \
        --rootfs btrfs \
        "{{image}}:{{tag}}"
    echo ""
    echo "ISO pronta: $(pwd)/output/bootiso/install.iso"
