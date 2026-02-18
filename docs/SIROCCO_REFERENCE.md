# Sirocco Quick Reference

## Hardware Specifications

- **Hostname**: sirocco
- **CPU**: Intel i7-4770 (Haswell, 4 cores/8 threads)
- **GPU**: NVIDIA GTX 1070
- **Storage**: 1TB SSD
- **Wi-Fi**: ASUS PCE-AC68 (Broadcom BCM4360)
- **Motherboard**: UEFI

## Quick Commands

### Build Custom Installer ISO

```bash
cd ~/nix-config
nix build .#nixosConfigurations.installer-iso.config.system.build.isoImage
ls -lh result/iso/
```

### Install NixOS

```bash
# From the custom installer ISO:
git clone https://github.com/kaigravy/nix-config.git
cd nix-config

# Verify disk device (update disks.nix if not /dev/sda)
lsblk

./install.sh sirocco
```

### Rebuild System

```bash
cd ~/nix-config
sudo nixos-rebuild switch --flake .#sirocco
```

### Generate Hardware Config

```bash
# On the installed system:
sudo nixos-generate-config --show-hardware-config

# Or during installation (before reboot):
nixos-generate-config --show-hardware-config --root /mnt
```

### Wi-Fi Troubleshooting

```bash
# Check if Wi-Fi driver is loaded
lsmod | grep wl

# Check Wi-Fi device
lspci | grep -i network
ip link show

# Manually load driver if needed
sudo modprobe wl

# Connect to Wi-Fi
nmcli device wifi list
nmcli device wifi connect "SSID" password "PASSWORD"
```

### NVIDIA Troubleshooting

```bash
# Check NVIDIA driver
nvidia-smi
lsmod | grep nvidia

# Check Xorg log
cat /var/log/X.0.log | grep -i nvidia
```

## Important Paths

- **Persist root**: `/persist`
- **User home**: `/users/kai` → `/persist/users/kai`
- **Config files**: `/persist/users/kai/.config` (via evict)
- **Secrets**: `/run/secrets/`

## Key Files

- **Host config**: `hosts/sirocco/default.nix`
- **Disk layout**: `hosts/sirocco/disks.nix`
- **Hardware**: `hosts/sirocco/hardware.nix`
- **Flake**: `flake.nix`

## Default Passwords Location

After installation, password hashes are stored in:
- `/persist/passwords/kai`
- `/persist/passwords/root`

## Recovery

If you need to access the system before impermanence rollback:

```bash
# Boot into installer ISO
sudo cryptsetup luksOpen /dev/sda2 cryptroot  # or your LUKS partition
sudo mount /dev/mapper/cryptroot /mnt -t btrfs -o subvol=@root
# Your files are in /mnt
```

## Disk Layout (disko)

```
/dev/sda
├── /dev/sda1     1GB    EFI System Partition → /boot
└── /dev/sda2     999GB  LUKS encrypted
    └── cryptroot        Btrfs with subvolumes:
        ├── @root        → /         (ephemeral)
        ├── @home        → /users    (ephemeral)
        ├── @nix         → /nix      (persistent)
        ├── @persist     → /persist  (persistent)
        └── @snapshots   → /.snapshots
```

## Kernel Modules

- **NVIDIA**: proprietary nvidia driver (no nouveau)
- **Wi-Fi**: `wl` (Broadcom proprietary)
- **Blacklisted**: `b43`, `bcma`, `ssb`, `brcmsmac`, `brcmfmac` (conflicts with `wl`)

## Notes

- Root (`/`) and user home (`/users`) are wiped on every boot
- Only `/persist` and `/nix` survive reboots
- LUKS passphrase required at boot
- NetworkManager manages Wi-Fi (not wpa_supplicant)
- NVIDIA proprietary driver is required (open-source not available for GTX 1070)
