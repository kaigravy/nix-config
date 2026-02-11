# Filen CLI Setup Guide

This guide covers the complete setup for automatic Filen cloud sync with encrypted credentials.

## Overview

- **Authentication**: Stored as encrypted secret via SOPS
- **Sync Directories**: Desktop and Documents (in `/users/kai/home/`)
- **Config Location**: Ephemeral (`/users/kai/config/.config/filen-cli/`)
- **Secret Management**: sops-nix with age encryption
- **Auto-sync**: Systemd user service

## Quick Start

### 1. Generate Age Key

```bash
cd secrets
nix-shell

sudo mkdir -p /persist/sops
age-keygen -o /persist/sops/age-keys.txt
sudo chmod 600 /persist/sops/age-keys.txt
```

**Important**: Save the public key (starts with `age1...`) shown in the output.

### 2. Update .sops.yaml

Edit `.sops.yaml` and replace the placeholder:

```yaml
keys:
  - &kai age1your_actual_public_key_here  # ← Replace this
```

### 3. Prepare Filen Auth Config

Get your Filen authentication details. The auth config should look like:

```json
{
  "email": "your-email@example.com",
  "password": "your-encrypted-password-hash",
  "twoFactorKey": "optional-2fa-key"
}
```

### 4. Encrypt Your Secret

```bash
# Still in secrets directory nix-shell
sops secrets.yaml
```

In your editor, replace the placeholder with your actual auth config:

```yaml
filen-cli-auth: |
  {
    "email": "your-email@example.com",
    "password": "your-password-hash",
    "twoFactorKey": "optional"
  }
```

Save and exit. SOPS will encrypt it automatically.

### 5. Rebuild System

```bash
sudo nixos-rebuild switch --flake .#vm
```

### 6. Verify

After rebuild:

```bash
# Check if secret is decrypted
ls -la /run/secrets/filen-cli-auth

# Check if config is symlinked
ls -la /users/kai/config/.config/filen-cli/

# Check service status
systemctl --user status filen-sync
```

## Troubleshooting

### Service Not Starting

Check if auth config exists:

```bash
cat /users/kai/config/.config/filen-cli/.filen-cli-auth-config
```

If missing, verify:
1. Secret exists: `ls /run/secrets/filen-cli-auth`
2. Rebuild was successful: `sudo nixos-rebuild switch --flake .#vm`

### Editing Secrets Later

```bash
cd secrets
nix-shell
sops secrets.yaml
```

### Manual Sync Test

```bash
# Set config directory
export XDG_CONFIG_HOME=/users/kai/config

# Test sync
filen sync --continuous
```

### Adding New Machine

1. Generate age key on new machine (in `secrets/` with `nix-shell`)
2. Get the new public key
3. Add to `.sops.yaml` in your repo
4. Update encrypted files with new key:
   ```bash
   cd secrets && nix-shell
   sops updatekeys secrets.yaml
   ```
5. Push changes to git
6. Pull and rebuild on new machine

## Files Modified

- `flake.nix` - Added sops-nix input
- `modules/nixos/sops.nix` - SOPS configuration
- `modules/home/filen.nix` - Updated to use secrets
- `.sops.yaml` - SOPS key configuration
- `secrets/secrets.yaml` - Encrypted secrets storage

## Security Notes

- Age key stored in `/persist/sops/` (survives reboots)
- Secrets decrypted to `/run/secrets/` (tmpfs, cleared on reboot)
- Auth config symlinked to ephemeral config dir
- No sensitive data persists after reboot except in encrypted form
- Safe to commit `secrets/secrets.yaml` (it's encrypted)
- **Never** commit `/persist/sops/age-keys.txt` (private key!)

## What Syncs

- **Desktop**: `/users/kai/home/Desktop` ↔ `/Desktop` (cloud)
- **Documents**: `/users/kai/home/Documents` ↔ `/Documents` (cloud)
- **Mode**: Two-way sync (changes in both directions)
- **Continuous**: Runs as systemd service, always syncing

## Persistence

These directories persist across reboots:
- `/users/kai/home/Desktop`
- `/users/kai/home/Documents`
- `/users/kai/home/Downloads`
- `/persist/sops/` (age keys)

These are ephemeral (wiped on reboot):
- `/users/kai/config/` (entire directory)
- `/run/secrets/` (tmpfs)

The auth config is automatically deployed to the ephemeral config dir on each boot.
