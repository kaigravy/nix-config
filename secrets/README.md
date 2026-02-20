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

### Adding SSH keys

SSH keys are also managed via sops. Open the file for editing:

```bash
sops secrets.yaml
```

Add (or extend) the `ssh` section:

```yaml
ssh:
  id_ed25519: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    <paste your private key here>
    -----END OPENSSH PRIVATE KEY-----
  id_ed25519_pub: "ssh-ed25519 AAAA... kai@hostname"
```

Save and exit. On next reboot (with `age-keys.txt` present) the keys will appear
at `/users/kai/.ssh/id_ed25519` and `/users/kai/.ssh/id_ed25519.pub`.

**Bootstrap flow on a new machine:**

1. Build and install as normal — the system works fine without SSH keys.
2. Boot into the new install.
3. Copy your `age-keys.txt` to `/persist/sops/age-keys.txt` (mode `0600`, owned by root).
4. Reboot. sops decrypts the keys and places them in `~/.ssh/` automatically.

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
3. **Runtime decryption**: sops-nix decrypts secrets at boot via a systemd service
4. **Direct placement**: SSH keys are written to `/users/kai/.ssh/` (persistent) at their
   final paths — no symlinks needed
5. **Other secrets**: Service credentials land in `/run/secrets/` (tmpfs, cleared on reboot)
6. **Graceful degradation**: If `age-keys.txt` is absent the system boots normally;
   secrets simply aren't populated until you add the key and reboot

## Security

- ✅ Private key: `/persist/sops/age-keys.txt` (never commit!)
- ✅ Encrypted secrets: `secrets.yaml` (safe to commit)
- ✅ Decrypted secrets: `/run/secrets/` (tmpfs, cleared on reboot)
- ✅ Safe failure: Won't break if secrets missing on new install
