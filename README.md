# veloxos

Custom [bootc](https://github.com/bootc-dev/bootc) image based on [origami-nvidia](https://gitlab.com/origami-linux/images), built and distributed via GitHub Container Registry.

## Install

Boot the ISO from the [Actions](https://github.com/dexmodzz/veloxos/actions) artifacts, or switch from an existing bootc system:

```bash
bootc switch ghcr.io/dexmodzz/veloxos:latest
```

## Build locally

```bash
just build
just build-iso    # generate installer ISO
just run-vm-iso   # test in a local VM
```
