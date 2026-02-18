# nix-config

NixOS configuration with btrfs, LUKS encryption, impermanence, and declarative disk management.

## Hosts

| Host | Description | Status |
|------|-------------|--------|
| `vm` | QEMU/KVM test VM | Active |
| `sirocco` | Desktop workstation (i7-4770, GTX 1070, ASUS PCE-AC68 Wi-Fi) | Ready |
| `installer-iso` | Custom NixOS installer with Wi-Fi drivers | ISO builder |

## Install

### Prerequisites

- Boot the [NixOS 25.11 graphical ISO](https://nixos.org/download/)
  - **For sirocco (desktop with ASUS PCE-AC68 Wi-Fi)**: Build and use the custom installer ISO (see below)
- Connect to the internet

### Building Custom Installer ISO (for sirocco)

The ASUS PCE-AC68 Wi-Fi card requires proprietary Broadcom drivers not included in the standard NixOS ISO.

```bash
# Build the custom ISO with Wi-Fi drivers
nix build .#nixosConfigurations.installer-iso.config.system.build.isoImage

# Flash to USB drive (replace /dev/sdX with your USB device)
sudo dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

See [`docs/SIROCCO_INSTALL.md`](docs/SIROCCO_INSTALL.md) for detailed installation instructions for the desktop.

### Steps

1. Clone this repo:

   ```
   nix-shell -p git
   git clone https://github.com/kaigravy/nix-config.git
   cd nix-config
   ```

2. Run the install script (partitions, formats, creates the blank btrfs snapshot,
   installs NixOS, and prompts you for passwords — all in one command):

   ```
   ./install.sh vm
   ```

   You will be prompted for the root password and the LUKS passphrase if needed.

3. Reboot:

   ```
   sudo reboot
   ```

### Post-install

After rebooting:

- The LUKS passphrase is prompted during boot
- Root (`/`) is wiped on every boot via btrfs snapshot rollback
- Only paths declared in `modules/nixos/impermanence.nix` persist across reboots
- If something is missing after a reboot, add it to the impermanence config and rebuild:

  ```
  sudo nixos-rebuild switch --flake .#vm
  ```

## Structure

```
├── flake.nix                     # Entry point
├── install.sh                    # One-command installer
├── .sops.yaml                    # SOPS configuration
├── secrets/
│   ├── secrets.yaml              # Encrypted secrets (SOPS)
│   ├── shell.nix                 # Dev environment for secret management
│   └── README.md                 # Secret management guide
├── hosts/
│   ├── common/default.nix        # Shared configuration
│   └── vm/
│       ├── default.nix           # VM-specific config
│       ├── disks.nix             # Disk layout (disko)
│       └── hardware.nix          # Hardware config
├── modules/
│   ├── nixos/                    # System modules
│   │   ├── boot.nix              # Bootloader + btrfs rollback
│   │   ├── btrfs.nix             # btrfs support
│   │   ├── gnome.nix             # GNOME desktop (swappable)
│   │   ├── impermanence.nix      # Persistent state declarations
│   │   ├── locale.nix            # Timezone + i18n
│   │   ├── networking.nix        # Network config
│   │   ├── nix-settings.nix      # Nix daemon settings
│   │   ├── sops.nix              # Secret management
│   │   └── users.nix             # User accounts
│   └── home/                     # Home-manager modules
│       ├── default.nix           # Base home config
│       ├── filen.nix             # Filen cloud sync
│       ├── git.nix               # Git
│       └── shell.nix             # Shell environment
```

## Secret Management

This configuration uses [sops-nix](https://github.com/Mic92/sops-nix) with age encryption for managing secrets like the Filen CLI authentication config.

### Quick Start

```bash
# Enter secrets environment
cd secrets && nix-shell

# Generate age key (first time)
sudo mkdir -p /persist/sops
age-keygen -o /persist/sops/age-keys.txt
sudo chmod 600 /persist/sops/age-keys.txt

# Copy the public key shown, edit ../.sops.yaml and add it

# Edit and encrypt secrets
sops secrets.yaml
```

See `secrets/README.md` for detailed instructions.

## Structure

```
├── flake.nix                     # Entry point
├── install.sh                    # One-command installer
├── docs/
│   ├── SIROCCO_INSTALL.md        # Desktop installation guide
│   └── FILEN_SETUP.md            # Filen sync setup
├── hosts/
│   ├── common/default.nix        # Shared configuration
│   ├── installer-iso/            # Custom installer with Wi-Fi drivers
│   │   └── default.nix
│   ├── vm/
│   │   ├── default.nix           # VM-specific config
│   │   ├── disks.nix             # Disk layout (disko)
│   │   └── hardware.nix          # Hardware config
│   └── sirocco/                  # Desktop configuration
│       ├── default.nix
│       ├── disks.nix             # 1TB SSD layout
│       └── hardware.nix          # NVIDIA + Wi-Fi drivers
├── modules/
│   ├── nixos/                    # System modules
│   │   ├── boot.nix              # Bootloader + btrfs rollback
│   │   ├── btrfs.nix             # btrfs support
│   │   ├── gnome.nix             # GNOME desktop (swappable)
│   │   ├── impermanence.nix      # Persistent state declarations
│   │   ├── locale.nix            # Timezone + i18n
│   │   ├── networking.nix        # Network config
│   │   ├── nix-settings.nix      # Nix daemon settings
│   │   ├── sops.nix              # Secret management
│   │   └── users.nix             # User accounts
│   └── home/                     # Home-manager modules
│       ├── default.nix           # Base home config
│       ├── filen.nix             # Filen cloud sync
│       ├── git.nix               # Git
│       └── shell.nix             # Shell environment
└── secrets/                      # SOPS encrypted secrets
```

## Adding a new host

1. Create `hosts/<hostname>/` with `default.nix`, `disks.nix`, and `hardware.nix`
2. Generate `hardware.nix` on the target machine (boot the ISO, then run):

   ```
   nixos-generate-config --no-filesystems --show-hardware-config > hardware.nix
   ```

   `--no-filesystems` is needed because disko manages mounts. For VMs, the
   `qemu-guest.nix` profile works without generating.
3. Add a `nixosConfigurations.<hostname>` entry in `flake.nix`
4. Adjust `disks.nix` for the target disk device and layout
5. Install with `./install.sh <hostname>`
