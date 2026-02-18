# Sirocco Installation Guide

This guide walks you through installing NixOS on the desktop machine "sirocco" with the ASUS PCE-AC68 Wi-Fi card.

## Hardware Overview

- **CPU**: Intel i7-4770 (Haswell)
- **GPU**: NVIDIA GTX 1070
- **Storage**: 1TB SSD
- **Wi-Fi**: ASUS PCE-AC68 (Broadcom BCM4360)
- **Firmware**: UEFI

## Step 1: Build the Custom Installer ISO

The custom ISO includes the Broadcom Wi-Fi drivers needed for your ASUS PCE-AC68.

From your working NixOS system or another Linux machine with Nix installed:

```bash
cd /path/to/nix-config

# Build the custom installer ISO
nix build .#nixosConfigurations.installer-iso.config.system.build.isoImage

# The ISO will be in: result/iso/
ls -lh result/iso/
```

The ISO file will be something like `nixos-25.11-x86_64-linux.iso`.

### Flash the ISO to a USB Drive

```bash
# Identify your USB drive (be careful!)
lsblk

# Flash the ISO (replace /dev/sdX with your USB drive)
sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync conv=fsync

# Verify the write was successful
sudo sync
```

**Alternative method if dd doesn't work:**

```bash
# Using Ventoy (more reliable for UEFI boot)
# Or use a GUI tool like Etcher, Rufus (Windows), or balenaEtcher

# Or use cp (simpler, sometimes more reliable)
sudo cp result/iso/nixos-*.iso /dev/sdX
sudo sync
```

### Verify the ISO Built Correctly

Before flashing, check the ISO was built successfully:

```bash
# Check the ISO file exists and has reasonable size (should be 2-3 GB)
ls -lh result/iso/

# Verify it's a valid ISO9660 filesystem
file result/iso/nixos-*.iso

# Expected output: "ISO 9660 CD-ROM filesystem data..."
```

## Step 2: Boot from the USB Drive

1. Insert the USB drive into your desktop
2. Reboot and enter BIOS/UEFI (usually F2, F12, or DEL)
3. **Important BIOS settings:**
   - Set boot mode to **UEFI** (not Legacy/CSM/BIOS)
   - Disable Secure Boot (if enabled)
   - Set USB boot priority to first
4. Save BIOS settings and boot from the USB drive

**If you see a blinking cursor:**
- Try pressing ESC or Space during boot to see if bootloader menu appears
- Check BIOS boot order - make sure USB is first
- Try a different USB port (USB 2.0 ports sometimes work better than 3.0)
- Verify UEFI mode is enabled (not Legacy BIOS)
- Try re-flashing the USB drive with a different tool

## Step 3: Connect to Wi-Fi

Once booted into the graphical installer:

```bash
# First, manually load the Broadcom Wi-Fi driver
# (It's not auto-loaded to prevent boot issues)
sudo modprobe wl

# Check if the wireless interface is detected
ip link show

# Connect using NetworkManager GUI (GNOME Settings)
# OR use nmcli:
nmcli device wifi list
nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"

# Verify connectivity
ping -c 3 nixos.org
```

If the Wi-Fi card isn't working, check:

```bash
# Verify the Broadcom driver is loaded
lsmod | grep wl

# Check for the PCI device
lspci | grep -i network

# If needed, manually load the driver
sudo modprobe wl
```

## Step 4: Identify Your SSD Device

```bash
# List all block devices
lsblk

# Your 1TB SSD should appear as /dev/sda, /dev/nvme0n1, or similar
# Note the exact device name (you'll need it for the next step)
```

## Step 5: Update Disk Configuration (if needed)

If your SSD device is **not** `/dev/sda`, you need to update the disk configuration:

```bash
# Clone your config repo
git clone https://github.com/kaigravy/nix-config.git
cd nix-config

# Edit the disk configuration
nano hosts/sirocco/disks.nix

# Change the device line to match your SSD:
# device = "/dev/nvme0n1";  # or whatever lsblk showed
```

## Step 6: Run the Installation

```bash
cd nix-config

# Run the installation script
./install.sh sirocco
```

The script will:
1. Partition and format your SSD
2. Set up LUKS encryption (you'll be prompted for a passphrase)
3. Create btrfs subvolumes
4. Mount everything
5. Create blank snapshots for impermanence
6. Install NixOS
7. Install the bootloader
8. Prompt you to set passwords for `kai` and `root`

## Step 7: Generate Hardware Configuration (Optional but Recommended)

After the installation, before rebooting, you can update the hardware configuration with the actual detected hardware:

```bash
# Generate hardware config
nixos-generate-config --show-hardware-config --root /mnt > /tmp/hardware.nix

# Review and copy relevant parts to your repo
cat /tmp/hardware.nix

# You can update hosts/sirocco/hardware.nix with this information later
```

## Step 8: Reboot

```bash
sudo reboot
```

Remove the USB drive when prompted.

## Post-Installation

### First Boot

1. You'll be prompted for your LUKS passphrase
2. GNOME should start automatically
3. Log in as user `kai` with the password you set during installation

### Verify Everything Works

```bash
# Check Wi-Fi is working
nmcli device status

# Check NVIDIA driver
nvidia-smi

# Check impermanence is working
ls /persist
ls /

# After reboot, root should be wiped
```

### Update Hardware Configuration (Recommended)

If you didn't generate the hardware config during installation:

```bash
cd ~/nix-config  # or wherever you cloned it

# Generate the hardware configuration
sudo nixos-generate-config --show-hardware-config > /tmp/hw.nix

# Review it
cat /tmp/hw.nix

# Update hosts/sirocco/hardware.nix with the relevant parts
# Keep the NVIDIA and Wi-Fi driver configuration we added!
```

### Rebuild After Hardware Config Update

```bash
cd ~/nix-config
sudo nixos-rebuild switch --flake .#sirocco
```

## Troubleshooting

### Blinking Cursor / Black Screen on Boot

If you see only a blinking cursor after installation:

**This is usually caused by the "silent boot" hiding error messages.** Temporarily disable it:

```bash
# Boot from the installer USB again
# Mount your system
sudo cryptsetup luksOpen /dev/sda2 cryptroot  # or your LUKS partition
sudo mount /dev/mapper/cryptroot /mnt -t btrfs -o subvol=@root
sudo mount /dev/sda1 /mnt/boot  # ESP partition
sudo mount /dev/mapper/cryptroot /mnt/nix -t btrfs -o subvol=@nix
sudo mount /dev/mapper/cryptroot /mnt/persist -t btrfs -o subvol=@persist

# Enter the system
sudo nixos-enter --root /mnt

# Temporarily disable silent boot to see errors
# Edit /persist/users/kai/nix-config/modules/nixos/boot.nix or add to hosts/sirocco/hardware.nix:
cat >> /persist/users/kai/nix-config/hosts/sirocco/hardware.nix << 'EOF'

  # DEBUG: Disable silent boot to see errors
  boot.plymouth.enable = lib.mkForce false;
  boot.consoleLogLevel = lib.mkForce 7;
  boot.initrd.verbose = lib.mkForce true;
  boot.kernelParams = lib.mkForce [];
  boot.loader.timeout = lib.mkForce 5;
EOF

# Rebuild
cd /persist/users/kai/nix-config
nixos-rebuild boot --flake .#sirocco

# Exit and reboot
exit
sudo reboot
```

Now you'll see verbose boot messages showing what's failing.

**Common causes:**
1. **Wrong disk device** in `disks.nix` - verify it's actually `/dev/sda`
2. **ESP not mounted** - check `/boot` has files after install
3. **Bootloader not installed** - check `/boot/EFI/systemd` exists
4. **NVIDIA driver issues** - try booting with `nomodeset` kernel parameter
5. **Wrong BIOS mode** - ensure UEFI mode is enabled, not Legacy/CSM

### Wi-Fi Not Working

If Wi-Fi doesn't work after installation:

```bash
# Check if the driver is loaded
lsmod | grep wl

# Check kernel messages
dmesg | grep -i broadcom

# Try rebuilding with verbose output
sudo nixos-rebuild switch --flake .#sirocco --show-trace
```

### NVIDIA Issues

If you have display issues:

```bash
# Check NVIDIA driver is loaded
lsmod | grep nvidia

# Check Xorg logs
cat /var/log/X.0.log | grep -i nvidia

# Verify the driver version
nvidia-smi
```

### LUKS Unlock Issues

If you can't unlock at boot:

- Make sure you're entering the correct passphrase
- Check keyboard layout (it defaults to US)
- Try using a simple passphrase during testing

### Impermanence Issues

If files are missing after reboot:

```bash
# Check what's persisted
cat /etc/nixos/configuration.nix | grep -A 20 environment.persistence

# Add missing paths to modules/nixos/impermanence.nix
# Then rebuild:
sudo nixos-rebuild switch --flake .#sirocco
```

## Notes

- **Disk Device**: The config assumes `/dev/sda`. Verify with `lsblk` and update `hosts/sirocco/disks.nix` if different.
- **Wi-Fi Drivers**: The Broadcom driver (`wl`) is proprietary but necessary for the ASUS PCE-AC68.
- **NVIDIA Driver**: Using the stable proprietary driver. GTX 1070 doesn't support the open-source kernel modules.
- **Impermanence**: Remember that `/` and `/users` are wiped on every boot! Only `/persist` and `/nix` survive.

## Next Steps

After successful installation:

1. Set up secrets (see `secrets/README.md`)
2. Configure Filen sync (see `docs/FILEN_SETUP.md`)
3. Customize your home-manager configuration in `modules/home/`
4. Add any additional packages or services you need
