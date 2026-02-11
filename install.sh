#!/usr/bin/env bash
set -euo pipefail

HOST="${1:?Usage: ./install.sh <host>}"

# 1. Partition, format, and mount
echo "==> Partitioning and formatting (you will be prompted for a LUKS passphrase)..."
sudo nix run --extra-experimental-features 'nix-command flakes' \
  github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake ".#$HOST"

# 2. Ensure ESP is mounted (disko bug: sometimes skips ESP mount)
if ! mountpoint -q /mnt/boot 2>/dev/null; then
  echo "==> Mounting ESP at /mnt/boot..."
  sudo mkdir -p /mnt/boot
  # Find an unmounted EFI System Partition (filter out the ISO's own ESP)
  ESP=$(lsblk -nrpo NAME,PARTTYPE,MOUNTPOINT 2>/dev/null \
    | grep -i 'c12a7328-f81f-11d2-ba4b-00a0c93ec93b' \
    | awk '$3=="" {print $1}' \
    | head -1)
  if [ -z "$ESP" ]; then
    echo "ERROR: Could not find an unmounted ESP partition."
    echo "Mount it manually: sudo mount /dev/<esp-partition> /mnt/boot"
    exit 1
  fi
  sudo mount "$ESP" /mnt/boot
fi

# Verify critical mounts before proceeding
echo "==> Verifying mounts..."
for mp in /mnt /mnt/boot /mnt/nix /mnt/persist /mnt/users; do
  if ! mountpoint -q "$mp" 2>/dev/null; then
    echo "ERROR: $mp is not mounted. Aborting."
    exit 1
  fi
done
echo "    All mount points OK."

# 3. Create blank snapshots for impermanence rollback
echo "==> Creating blank snapshots for ephemeral subvolumes..."
sudo mount /dev/mapper/cryptroot /mnt/.snapshots-setup -t btrfs -o subvol=/ 2>/dev/null || {
  sudo mkdir -p /mnt/.snapshots-setup
  sudo mount /dev/mapper/cryptroot /mnt/.snapshots-setup -t btrfs -o subvol=/
}
for subvol in @root @home; do
  if [ ! -d "/mnt/.snapshots-setup/${subvol}-blank" ]; then
    sudo btrfs subvolume snapshot -r "/mnt/.snapshots-setup/$subvol" "/mnt/.snapshots-setup/${subvol}-blank"
  fi
done
sudo umount /mnt/.snapshots-setup

# 4. Install NixOS
echo "==> Installing NixOS..."
sudo nixos-install --no-root-passwd --flake ".#$HOST"

# 5. Verify bootloader was installed
if [ ! -d /mnt/boot/EFI/systemd ] && [ ! -d /mnt/boot/EFI/BOOT ]; then
  echo "WARNING: Bootloader may not have been installed correctly."
  echo "Attempting manual bootloader install..."
  sudo nixos-enter --root /mnt -- bootctl install
fi

# 6. Set up passwords
sudo mkdir -p /mnt/persist/passwords
echo "==> Set password for user 'kai':"
mkpasswd -m sha-512 | sudo tee /mnt/persist/passwords/kai > /dev/null
echo "==> Set password for root:"
mkpasswd -m sha-512 | sudo tee /mnt/persist/passwords/root > /dev/null

echo "==> Done! Run 'sudo reboot' to boot into your new system."
