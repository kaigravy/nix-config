# Secrets Directory

This directory contains encrypted secrets managed by SOPS with age encryption.

## Files

- `secrets.yaml` - Encrypted secrets file
- `shell.nix` - Development environment with sops and age tools
- `.gitignore` - Ensures unencrypted files aren't committed

## Quick Start

### 1. Enter the secrets environment

```bash
cd secrets
nix-shell
```

This loads `sops` and `age` commands and sets `SOPS_AGE_KEY_FILE` automatically.

### 2. Generate age key (first time only)

```bash
sudo mkdir -p /persist/sops
age-keygen -o /persist/sops/age-keys.txt
sudo chmod 600 /persist/sops/age-keys.txt
sudo chown root:root /persist/sops/age-keys.txt
```

The output shows your **public key** (starts with `age1...`). Copy it.

### 3. Update .sops.yaml

Edit `../.sops.yaml` and replace the placeholder with your public key:

```yaml
keys:
  - &kai age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 4. Edit secrets

```bash
sops secrets.yaml
```

Replace the placeholder with your Filen CLI auth config:

```yaml
filen-cli-auth: |
  {
    "email": "your-email@example.com",
    "password": "your-encrypted-password",
    "twoFactorKey": "optional"
  }
```

Save and exit. SOPS encrypts automatically.

### 5. Rebuild system

```bash
cd ..
sudo nixos-rebuild switch --flake .#vm
```

## Common Operations

All commands should be run from within `nix-shell` in this directory:

```bash
# Enter environment
cd secrets && nix-shell

# Show your public key
grep "# public key:" /persist/sops/age-keys.txt

# Edit secrets
sops secrets.yaml

# Manually decrypt to stdout (for debugging)
sops -d secrets.yaml

# Update keys after adding a new machine
sops updatekeys secrets.yaml
```

## How It Works

1. **Age key**: Private key in `/persist/sops/age-keys.txt` (persists across reboots)
2. **Encrypted storage**: `secrets.yaml` encrypted with your public key (safe to commit)
3. **Runtime decryption**: sops-nix decrypts to `/run/secrets/` on boot
4. **Deployment**: Home-manager symlinks to your config directory
5. **Ephemeral**: Config dir wiped on reboot, secret auto-deployed each boot

## Security

- ✅ Private key: `/persist/sops/age-keys.txt` (never commit!)
- ✅ Encrypted secrets: `secrets.yaml` (safe to commit)
- ✅ Decrypted secrets: `/run/secrets/` (tmpfs, cleared on reboot)
- ✅ Safe failure: Won't break if secrets missing on new install
