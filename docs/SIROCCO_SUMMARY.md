# Sirocco Configuration Summary

This document summarizes the NixOS configuration created for the desktop machine "sirocco".

## What Was Created

### 1. Host Configuration (`hosts/sirocco/`)

Three files define the sirocco host:

#### `default.nix`
- Imports common configuration and host-specific files
- Sets hostname to "sirocco"

#### `disks.nix` 
- Disko configuration for the 1TB SSD
- Default device: `/dev/sda` (verify with `lsblk` and update if needed)
- Partitioning scheme:
  - 1GB EFI System Partition (ESP) → `/boot`
  - Remaining space → LUKS encrypted btrfs
- Btrfs subvolumes:
  - `@root` → `/` (ephemeral, wiped on boot)
  - `@home` → `/users` (ephemeral, wiped on boot)
  - `@nix` → `/nix` (persistent)
  - `@persist` → `/persist` (persistent)
  - `@snapshots` → `/.snapshots`

#### `hardware.nix`
- Hardware-specific configuration
- **NVIDIA GTX 1070**: Proprietary driver configuration
- **ASUS PCE-AC68 Wi-Fi**: Broadcom `wl` driver with blacklists for conflicting drivers
- **Intel i7-4770**: CPU microcode updates
- **32-bit support**: Enabled for Steam and other applications
- Note: This is a template; you should generate the actual hardware config in the installer

### 2. Custom Installer ISO (`hosts/installer-iso/`)

A custom NixOS installer ISO that includes:

- **Broadcom Wi-Fi drivers** (`wl` module for ASUS PCE-AC68)
- **GNOME desktop** for easier installation
- **NetworkManager** for Wi-Fi setup
- **Useful tools**: git, vim, htop, pciutils, cryptsetup, etc.
- **Flakes enabled** out of the box
- **Auto-login** as nixos user

Build with:
```bash
nix build .#nixosConfigurations.installer-iso.config.system.build.isoImage
```

### 3. Updated `flake.nix`

Added two new configurations:
- `sirocco` - The desktop host configuration
- `installer-iso` - The custom installer builder

### 4. Documentation

#### `docs/SIROCCO_INSTALL.md`
Comprehensive installation guide covering:
- Building the custom ISO
- Booting and Wi-Fi setup
- Running the installation
- Post-installation verification
- Troubleshooting common issues

#### `docs/SIROCCO_REFERENCE.md`
Quick reference card with:
- Hardware specs
- Common commands
- Important paths
- Disk layout
- Recovery procedures

## Installation Workflow

### Before Installation

1. **Build the custom ISO** (on any machine with Nix):
   ```bash
   nix build .#nixosConfigurations.installer-iso.config.system.build.isoImage
   ```

2. **Flash to USB**:
   ```bash
   sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
   ```

### During Installation

1. **Boot from USB** (UEFI mode)
2. **Connect to Wi-Fi** (should work automatically with the custom ISO)
3. **Verify disk device** with `lsblk`
4. **Update `disks.nix`** if SSD is not `/dev/sda`
5. **Run installer**:
   ```bash
   git clone https://github.com/kaigravy/nix-config.git
   cd nix-config
   ./install.sh sirocco
   ```
6. **Optional: Generate hardware config** before rebooting:
   ```bash
   nixos-generate-config --show-hardware-config --root /mnt > /tmp/hw.nix
   ```

### After Installation

1. **Reboot** and enter LUKS passphrase
2. **Log in** as user `kai`
3. **Verify Wi-Fi and NVIDIA** are working
4. **Update hardware config** if you didn't during installation
5. **Set up secrets** (see `secrets/README.md`)

## Key Differences from VM Config

| Aspect | VM | Sirocco |
|--------|-----|---------|
| Disk device | `/dev/vda` | `/dev/sda` (or `/dev/nvme0n1`) |
| Graphics | QXL/virtio | NVIDIA GTX 1070 |
| Network | virtio-net | ASUS PCE-AC68 Wi-Fi |
| Kernel modules | `kvm-intel`, virtio | `wl` (Broadcom), NVIDIA |
| Hardware profile | `qemu-guest.nix` | Custom with NVIDIA + Wi-Fi |
| Disk size | Variable | 1TB |

## Important Considerations

### 1. Disk Device Name
The configuration assumes `/dev/sda`. Modern systems might use:
- `/dev/nvme0n1` for NVMe SSDs
- `/dev/sdb` if you have another drive

**Always verify with `lsblk` before installation!**

### 2. Wi-Fi Drivers
The ASUS PCE-AC68 uses:
- Chipset: Broadcom BCM4360
- Driver: `wl` (proprietary)
- Conflicts with: `b43`, `bcma`, `ssb`, `brcmsmac`, `brcmfmac`

These conflicting drivers are blacklisted in the hardware config.

### 3. NVIDIA Drivers
- Using **proprietary** driver (nouveau doesn't work well with GTX 1070)
- **Stable** branch selected
- GTX 1070 does **not** support the new open-source kernel modules
- Set `open = false` in hardware config

### 4. Impermanence
Remember that everything in `/` and `/users` (except what's symlinked to `/persist`) is **wiped on every boot**!

Persistent locations:
- `/persist` - System state
- `/nix` - Nix store
- User home is managed by evict, which symlinks to `/persist/users/kai`

### 5. Hardware Config Generation
The `hardware.nix` file is a template with known hardware. You should still:
1. Generate the actual hardware config in the installer
2. Merge any additional modules detected
3. Keep the NVIDIA and Wi-Fi driver configuration

## Troubleshooting Checklist

- [ ] Wi-Fi card detected: `lspci | grep -i network`
- [ ] Wi-Fi driver loaded: `lsmod | grep wl`
- [ ] Can connect to Wi-Fi: `nmcli device wifi connect ...`
- [ ] NVIDIA driver loaded: `lsmod | grep nvidia`
- [ ] NVIDIA working: `nvidia-smi`
- [ ] Correct disk device in `disks.nix`
- [ ] UEFI boot mode enabled in BIOS
- [ ] Bootloader installed: `/boot/EFI/systemd` exists

## Next Steps After Installation

1. **Secrets setup**: Initialize SOPS with age keys
2. **Filen sync**: Configure cloud storage sync
3. **Customize**: Add any additional packages or services
4. **Backup**: Consider backing up `/persist` regularly
5. **Test impermanence**: Reboot and verify only persisted data remains

## Files to Review Before Installation

| File | Purpose | Action Required |
|------|---------|-----------------|
| `hosts/sirocco/disks.nix` | Disk layout | Verify device name (`/dev/sda`) |
| `hosts/sirocco/hardware.nix` | Hardware config | Generate actual config in installer (optional) |
| `flake.nix` | Top-level config | No changes needed |
| `install.sh` | Installation script | No changes needed |

## Questions to Consider

1. **Disk device**: Run `lsblk` to confirm - is it `/dev/sda`?
2. **Swap**: Do you want swap? (Not configured by default)
3. **Dual boot**: Will you keep another OS? (Would need separate ESP handling)
4. **Desktop environment**: Happy with GNOME or want something else?
5. **Gaming**: Need Steam, Lutris, etc.? (32-bit support already enabled)

Good luck with the installation! 🚀
