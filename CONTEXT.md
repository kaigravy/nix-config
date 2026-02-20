# System Context

> Hand this file to an AI assistant at the start of a new conversation so it has
> full context about this NixOS configuration repository.

## Repository

- **GitHub**: `kaigravy/nix-config` — NixOS flake-based configuration
- **Working directory**: `/workspaces/nix-config` (dev container, Ubuntu 24.04)

## Hosts

| Name | Role | Notes |
|------|------|-------|
| `sirocco` | Primary desktop | See below for hardware details |
| `mistral` | Secondary machine | Separate host config |
| `vm` | Local VM for testing | mirrors sirocco layout |
| `installer-iso` | Bootable install image | |

## Sirocco Hardware (primary machine)

- **CPU**: Intel i7-4770 (Haswell, 4c/8t)
- **GPU**: NVIDIA GTX 1070 — proprietary driver (`nvidia`, `modesetting.enable = true`)
- **Wi-Fi**: ASUS PCE-AC68 (Broadcom BCM4360) — `broadcom-sta` / `wl` module; conflicting
  open-source drivers are blacklisted (`b43`, `bcma`, `ssb`, `brcmsmac`, `brcmfmac`)
- **Disk**: `/dev/sda` — full-disk LUKS encryption → Btrfs

## Filesystem / Impermanence

Disk layout (Btrfs subvolumes inside LUKS):

| Subvolume | Mountpoint | Ephemeral? |
|-----------|------------|------------|
| `@root`     | `/`        | ✅ yes — rolled back to blank on every boot |
| `@nix`      | `/nix`     | ❌ persistent |
| `@persist`  | `/persist` | ❌ persistent (`neededForBoot = true`) |
| `@home`     | `/users`   | ❌ persistent (`neededForBoot = true`) |
| `@snapshots`| `/.snapshots` | ❌ persistent |

`/` is wiped at boot via a `boot.initrd.systemd` rollback service in `modules/nixos/boot.nix`.

Btrfs auto-scrub is enabled. `programs.fuse.userAllowOther = true` for bind mounts.

## Users

- Username: `kai`  
- Home directory: `/users/kai` (on the persistent `/users` filesystem)
- Shell: `zsh`
- Groups: `wheel`, `networkmanager`
- Passwords: `mutableUsers = false`; hashed password files at `/persist/passwords/kai` and
  `/persist/passwords/root`
- `users.defaultUserHome = "/users"`

## Evict (home directory layout)

Uses the [`evict`](https://github.com/TRPB/evict) home-manager module to split the home
directory into two subdirectories:

| Path | Purpose |
|------|---------|
| `/users/kai/home/` | Personal files (Documents, Downloads, Desktop, etc.) |
| `/users/kai/config/` | Application config files (dotfiles, XDG config) |

XDG user dirs (`Desktop`, `Documents`, `Downloads`) point into `home/`.  
This separation is important: **do not use `~` for config paths** in home-manager — use
`${config.home.homeDirectory}/${config.home.evict.configDirName}/...` where needed.

## Home-manager

Managed via `home-manager.nixosModules.home-manager` (not standalone). Entry point:
`modules/home/default.nix`. Modules:

- `cli.nix` — CLI tools
- `general-programs.nix` — misc GUI/TUI programs
- `shell.nix` — shell environment
- `zsh.nix` — zsh config
- `fonts.nix` — font packages
- `git.nix` — git (`programs.git`)
- `ssh.nix` — SSH client config (`programs.ssh`); declares `matchBlocks` for named keys
- `filen.nix` — Filen cloud CLI
- `emacs.nix` — Doom Emacs
- `kitty.nix` — Kitty terminal
- `zen-browser.nix` — Zen Browser

## Desktop

- **Display server**: X11 via `services.xserver.enable`
- **Desktop environment**: GNOME (`services.xserver.desktopManager.gnome.enable`)
- **Display manager**: GDM

## Secrets (sops-nix)

- **Tool**: `sops-nix` with age encryption
- **Key file**: `/persist/sops/age-keys.txt` (mode `0600`, owned root)
- **Secrets file**: `secrets/secrets.yaml` (encrypted, safe to commit)
- **`validateSopsFiles = false`** — system builds and boots even without the age key;
  secrets simply aren't populated until the key is present and the machine is rebooted

Current secrets (defined in `modules/nixos/sops.nix`):

| YAML path | Deployed to | Owner | Mode |
|-----------|-------------|-------|------|
| `filen-cli-auth` | `/run/secrets/filen-cli-auth` | kai | `0400` |
| `ssh/github` | `/users/kai/.ssh/github` | kai | `0600` |
| `ssh/github_pub` | `/users/kai/.ssh/github.pub` | kai | `0644` |

Adding a new secret: add an entry under `sops.secrets` in `modules/nixos/sops.nix`, then
add the plaintext value inside `sops secrets/secrets.yaml`.

SSH key naming convention: one named key pair per service (e.g. `ssh/work`, `ssh/work_pub`).
The matching `programs.ssh.matchBlocks` entry lives in `modules/home/ssh.nix`.

## Boot

- **Bootloader**: `systemd-boot` (EFI)
- **Plymouth**: enabled, theme `red_loader`
- **Silent boot**: `quiet`, `udev.log_level=3`, `loader.timeout = 0`
- **Rollback**: initrd systemd service deletes `@root` and restores from `@root-blank`
  on every boot (impermanence)

## Flake Inputs

| Input | Follows |
|-------|---------|
| `nixpkgs` | `nixos-25.11` |
| `home-manager` | `release-25.11` |
| `disko` | nixpkgs |
| `impermanence` | — |
| `evict` | — |
| `sops-nix` | nixpkgs |
| `zen-browser` | nixpkgs |

## Module Layout

```
modules/
  nixos/         # NixOS system modules (imported in hosts/common/default.nix)
    boot.nix
    btrfs.nix
    gnome.nix
    impermanence.nix
    locale.nix
    networking.nix
    nix-settings.nix
    sops.nix
    ssh.nix        # systemd-tmpfiles: creates /users/kai/.ssh
    users.nix
  home/          # home-manager modules (entry: modules/home/default.nix)
    default.nix
    cli.nix
    emacs.nix
    filen.nix
    fonts.nix
    general-programs.nix
    git.nix
    kitty.nix
    shell.nix
    ssh.nix        # programs.ssh matchBlocks
    zen-browser.nix
    zsh.nix
hosts/
  common/default.nix   # shared NixOS config + home-manager wiring
  sirocco/             # hostname-specific (hardware, disks, networking.hostName)
  mistral/
  vm/
  installer-iso/
secrets/
  secrets.yaml         # SOPS-encrypted secrets
  shell.nix            # nix-shell with sops + age, sets SOPS_AGE_KEY_FILE
config/
  doom/                # Doom Emacs config (config.el, init.el, packages.el)
  kitty/kitty.conf
```

## Common Conventions

- All paths use absolute references; never assume `~` for system-level config
- `nixpkgs.config.allowUnfree = true` is set (Broadcom + NVIDIA drivers)
- `nixpkgs.config.allowInsecurePredicate` matches by name (not version string) so it
  survives package bumps
- NixOS stateVersion: `25.11`
