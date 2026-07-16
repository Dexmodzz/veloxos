<div align="center">

```
                    ██╗   ██╗███████╗██╗      ██████╗ ██╗  ██╗ ██████╗ ███████╗
                    ██║   ██║██╔════╝██║     ██╔═══██╗╚██╗██╔╝██╔═══██╗██╔════╝
                    ██║   ██║█████╗  ██║     ██║   ██║ ╚███╔╝ ██║   ██║███████╗
                    ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║ ██╔██╗ ██║   ██║╚════██║
                     ╚████╔╝ ███████╗███████╗╚██████╔╝██╔╝ ██╗╚██████╔╝███████║
                      ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

[![Download](https://img.shields.io/badge/⬇️%20Download-ISO-blue?style=flat-square)](#-download)
[![Stars](https://img.shields.io/github/stars/Dexmodzz/veloxos?style=flat-square)](https://github.com/Dexmodzz/veloxos/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/Dexmodzz/veloxos?style=flat-square)](https://github.com/Dexmodzz/veloxos/commits/main)
[![Platform](https://img.shields.io/badge/platform-Linux-blue?style=flat-square&logo=linux)](https://kernel.org)
[![Shell](https://img.shields.io/badge/shell-Bash-4EAA25?style=flat-square&logo=gnubash)](https://www.gnu.org/software/bash/)

</div>

<h3 align="center">VeloxOS — a fast, ready-to-use Fedora bootc distro</h3>

<p align="center">
  Built by <b>Dexmodzz</b> · based on <b>Fedora Atomic (bootc)</b> · desktop <b>niri</b> + <b>DankMaterialShell</b>
</p>

---

<div align="center">
  
## 🖥️ What is VeloxOS

VeloxOS is a custom Linux image based on **Fedora Atomic (bootc)**: the operating system is shipped as an **immutable container image**, updated via `bootc` instead of a classic package manager. This means atomic updates, easy rollbacks if something goes wrong, and a base system that's always consistent and reproducible.

On top of this base, VeloxOS ships already configured and ready to use:

</div>

- **[niri](https://github.com/YaLTeR/niri)** — a fast, minimal scrollable-tiling window manager for Wayland.
- **[DankMaterialShell (DMS)](https://github.com/AvengeMedia/DankMaterialShell)** — a Material Design desktop shell (bar, launcher, notifications, panels) built on Quickshell.
- Pre-configured apps and tools: **kitty** terminal, **Thunar** file manager, a consistent GTK/Qt theme, Material fonts and cursors, Flatpak/Nix integration, and optional gaming and virtualization support.

<div align="center">

The goal is to offer a modern, responsive, "batteries included" desktop experience: there's no need to configure the window manager from scratch — VeloxOS comes with a complete, coherent, and pleasant environment out of the box.

</div>

<div align="center">

## 📥 Download

You can download the ready-made VeloxOS ISO image here:

**[⬇️ Download the VeloxOS ISO (Mega.nz)](https://mega.nz/file/w6kFzQ4J#Gy-etchjlaHhfIBIdnQ_XfMsmG2zGO-rwkV1jX23ITc)**

Once downloaded, write the ISO to a USB drive and start the installation by following the Anaconda setup wizard.

</div>

<div align="center">

### Creating a bootable USB drive

</div>

- **[Rufus](https://rufus.ie/) (Windows)** — open Rufus, select your USB drive, choose the downloaded VeloxOS ISO as the boot selection, and click **Start** to write it to the drive.
- **[BalenaEtcher](https://etcher.balena.io/) (Linux/Windows)** — open BalenaEtcher, click **Flash from file** and select the VeloxOS ISO, choose your USB drive as the target, then click **Flash** to write it.
- **`dd` (Linux/macOS)** — from a terminal, first list your drives to find the USB device:
  ```
  sudo lsblk
  ```
  Look for the drive matching your USB stick's size (e.g. 16G, 32G) and note its name — the whole disk (e.g. `sda`), not a partition (e.g. `sda1`). Then run:
  ```
  sudo dd if=veloxos.iso of=/dev/sdX bs=4M status=progress conv=fsync
  ```
</div>
  
Replace `/dev/sdX` with your actual USB device (not a partition, e.g. `/dev/sda`) — double-check it, as `dd` will silently overwrite the target drive.

Once the flash is complete, reboot your PC and boot from the USB drive to start the VeloxOS installer.

<div align="center">

## 📦 What you'll find in this repository

This repo contains everything needed to **build the VeloxOS image** (it's the distro's source code, not the ready-to-run distro itself):

</div>

| Path | Contents |
|---|---|
| `Containerfile` | bootc image definition (standard INTEL-driver NVIDIA-driver AMD-driver) work with all GPU drivers recognize at boot automatically |
| `build_files/` | Build scripts and user configuration files (dotfiles) included in the image: niri config, DankMaterialShell, kitty, GTK, fish, etc. |
| `system_files/` | System files copied into the image: `veloxos` binaries, systemd services, branding, policies |
| `spec_files/` | RPM specs for extra packages built and included in the image (e.g. Cemu, Ryujinx, lsfg-vk, xpadneo) |
| `disk_config/` | Configuration for generating disk images (qcow2, ISO, etc.) via `bootc-image-builder` |
| `installer/` | Support files for the system installer |
| `Justfile` | Commands to build, test, and run VeloxOS in a VM (`just build-vm`, `just run-vm`, etc.) |

In short: if you want to **use** VeloxOS, download/install the ready-made image; if you want to **modify or rebuild it**, this repo is the starting point.

<div align="center">

## 🛠️ The `veloxos` command

The system includes a terminal helper for managing extra packages and optional features without touching the immutable base:

</div>

| Command | Description |
|---|---|
| `veloxos install <package...>` | Install extra packages via overlay |
| `veloxos update` | Update overlay-installed packages |
| `veloxos remove <package...>` | Remove packages from the overlay |
| `veloxos list` | List overlay-installed packages |
| `veloxos system-upgrade` | Check for and apply system image upgrades |
| `veloxos reset-overlay --confirm` | Wipe the overlay and all installed packages |
| `veloxos reset-overlay --soft` | Rebuild the overlay while preserving the package list |
| `veloxos setup-gaming` | Set up native gaming packages plus some Flathub apps |
| `veloxos setup-virtualization` | Set up KVM/QEMU virtualization |
| `veloxos setup-lsfg-vk` | Set up Lossless Scaling Frame Generation |
| `veloxos setup-stoat` | Set up Stoat |
| `veloxos setup-ollama` | Set up Ollama for local AI |

<div align="center">

## ⌨️ Main keyboard shortcuts (niri + DMS)

The **Mod** key defaults to the **Super/Windows** key.

</div>

| Shortcut | Action |
|---|---|
| `Mod + Return` | Open a terminal (kitty) |
| `Mod + T` | Open a terminal (kitty) |
| `Mod + D` | Open the DankMaterialShell launcher/spotlight |
| `Mod + E` | Open the file manager (Thunar) |
| `Mod + B` | Open the browser (Brave) |
| `Mod + Shift + B` | Open the browser in incognito mode |
| `Super + Alt + L` | Lock the screen |
| `Mod + Q` | Close the focused window |
| `Mod + Shift + Slash` | Show the full list of shortcuts (hotkey overlay) |
| `Mod + Tab` | Open the window overview |
| `Mod + ←/→` or `Mod + H/L` | Move focus between columns |
| `Mod + ↓/↑` | Move focus between windows/workspaces vertically |
| `Mod + Shift + ←/→` or `Mod + Shift + H/L` | Move the focused column left/right |
| `Mod + 1..9` | Go to workspace N |
| `Mod + Shift + 1..9` | Move the column to workspace N |
| `Mod + Ctrl + ←/↑/↓/→` | Move focus to another monitor |
| `Mod + R` | Cycle preset column width |
| `Mod + Shift + R` | Cycle preset window height |
| `Mod + F` | Maximize the column |
| `Mod + Shift + F` | Fullscreen |
| `Mod + C` | Center the focused column |
| `Mod + V` | Toggle floating window mode |
| `Mod + O` | Toggle tabbed display mode for the column |
| `Mod + Space` | Switch keyboard layout |
| `Mod + Escape` | Toggle the keyboard shortcuts inhibitor (useful for remote desktop) |
| `Mod + Shift + E` | Quit niri (with confirmation) |
| `Mod + Shift + P` | Power off the monitors |
| `Print` | Screenshot |
| `Ctrl + Print` | Screenshot of the whole screen |
| `Alt + Print` | Screenshot of the focused window |
| `XF86AudioRaise/LowerVolume` | Volume up/down |
| `XF86AudioMute` | Mute/unmute audio |
| `XF86MonBrightnessUp/Down` | Brightness up/down |

> Tip: press `Mod + Shift + Slash` at any time to see the full, always up-to-date list of available shortcuts on screen.

## 🚀 Getting started

1. Download/install the VeloxOS (bootc) image following the project's instructions.
2. On first boot you'll already have: the niri + DankMaterialShell desktop, kitty terminal, Thunar file manager, and a consistent Material theme.
3. Use the `veloxos` command in the terminal to install extra packages, update the system, or enable optional features (gaming, virtualization, local AI).
4. To build the image from this repo, check the `Justfile` (`just --list` for the full list of available commands).

## 🔗 Useful links

- Bug reports/issues: https://github.com/Dexmodzz/veloxos/issues
- Home: https://github.com/Dexmodzz/veloxos
