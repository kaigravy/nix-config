#!/usr/bin/env bash
# Setup script for SOPS secret management

set -e

echo "=== SOPS Secret Management Setup ==="
echo

# Check if age key already exists
if [ -f /persist/sops/age-keys.txt ]; then
    echo "✓ Age key already exists at /persist/sops/age-keys.txt"
    echo
    echo "Your public key is:"
    grep "# public key:" /persist/sops/age-keys.txt | cut -d: -f2 | xargs
    echo
else
    echo "Creating age key..."
    sudo mkdir -p /persist/sops
    
    # Check if we're in a nix-shell with age available
    if ! command -v age-keygen &> /dev/null; then
        echo "Error: age-keygen not found. Please run this script in a nix-shell:"
        echo "  nix-shell -p age --run ./setup-secrets.sh"
        exit 1
    fi
    
    sudo age-keygen -o /persist/sops/age-keys.txt
    sudo chmod 600 /persist/sops/age-keys.txt
    sudo chown root:root /persist/sops/age-keys.txt
    
    echo
    echo "✓ Age key generated at /persist/sops/age-keys.txt"
    echo
    echo "Your public key is:"
    sudo grep "# public key:" /persist/sops/age-keys.txt | cut -d: -f2 | xargs
    echo
fi

echo
echo "Next steps:"
echo "1. Copy the public key shown above"
echo "2. Edit .sops.yaml and replace the placeholder key"
echo "3. Prepare your .filen-cli-auth-config file content"
echo "4. Run: SOPS_AGE_KEY_FILE=/persist/sops/age-keys.txt sops secrets/secrets.yaml"
echo "5. In the editor, replace the placeholder with your actual Filen auth config"
echo "6. Save and exit, then rebuild: sudo nixos-rebuild switch --flake .#vm"
echo
echo "To edit secrets later:"
echo "  SOPS_AGE_KEY_FILE=/persist/sops/age-keys.txt sops secrets/secrets.yaml"
echo
