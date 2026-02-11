# nix-config

NixOS configuration with btrfs, LUKS encryption, impermanence, and declarative disk management.

## Hosts

| Host | Description | Status |
|------|-------------|--------|
| `vm` | QEMU/KVM test VM | Active |
| `desktop` | Desktop workstation | Planned |
| `laptop` | Laptop | Planned |

## Install

### Prerequisites

- Boot the [NixOS 25.11 graphical ISO](https://nixos.org/download/)
- Connect to the internet

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
│   │   └── users.nix             # User accounts
│   └── home/                     # Home-manager modules
│       ├── default.nix           # Base home config
│       ├── git.nix               # Git
│       └── shell.nix             # Shell environment
└── overlays/
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
