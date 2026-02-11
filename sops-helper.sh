#!/usr/bin/env bash
# Quick reference for common SOPS operations

set -e

SOPS_KEY="/persist/sops/age-keys.txt"
SECRETS_FILE="secrets/secrets.yaml"

show_help() {
    cat << EOF
SOPS Secret Management - Quick Reference

Usage: ./sops-helper.sh [command]

Commands:
    setup       Generate age key and show public key
    edit        Edit encrypted secrets file
    show-key    Display your public key
    encrypt     Encrypt a file manually
    decrypt     Decrypt a file manually (to stdout)
    help        Show this help message

Examples:
    # Initial setup
    ./sops-helper.sh setup
    
    # Edit secrets
    ./sops-helper.sh edit
    
    # Show public key
    ./sops-helper.sh show-key

Environment:
    SOPS_AGE_KEY_FILE  Path to age key file (default: $SOPS_KEY)

EOF
}

ensure_sops() {
    if ! command -v sops &> /dev/null; then
        echo "Error: sops not found. Run this in a nix-shell:"
        echo "  nix-shell -p sops age --run './sops-helper.sh $1'"
        exit 1
    fi
}

ensure_age() {
    if ! command -v age-keygen &> /dev/null; then
        echo "Error: age not found. Run this in a nix-shell:"
        echo "  nix-shell -p age --run './sops-helper.sh $1'"
        exit 1
    fi
}

cmd_setup() {
    ensure_age
    
    if [ -f "$SOPS_KEY" ]; then
        echo "Age key already exists!"
        cmd_show_key
    else
        echo "Creating age key..."
        sudo mkdir -p "$(dirname "$SOPS_KEY")"
        sudo age-keygen -o "$SOPS_KEY"
        sudo chmod 600 "$SOPS_KEY"
        sudo chown root:root "$SOPS_KEY"
        echo
        echo "✓ Age key created!"
        cmd_show_key
        echo
        echo "Next: Add this public key to .sops.yaml"
    fi
}

cmd_edit() {
    ensure_sops
    
    if [ ! -f "$SOPS_KEY" ]; then
        echo "Error: Age key not found at $SOPS_KEY"
        echo "Run: ./sops-helper.sh setup"
        exit 1
    fi
    
    SOPS_AGE_KEY_FILE="$SOPS_KEY" sops "$SECRETS_FILE"
}

cmd_show_key() {
    if [ ! -f "$SOPS_KEY" ]; then
        echo "Error: Age key not found at $SOPS_KEY"
        echo "Run: ./sops-helper.sh setup"
        exit 1
    fi
    
    echo "Your public key:"
    sudo grep "# public key:" "$SOPS_KEY" | cut -d: -f2 | xargs
}

cmd_encrypt() {
    ensure_sops
    
    if [ -z "$1" ]; then
        echo "Usage: ./sops-helper.sh encrypt <file>"
        exit 1
    fi
    
    SOPS_AGE_KEY_FILE="$SOPS_KEY" sops -e "$1"
}

cmd_decrypt() {
    ensure_sops
    
    if [ -z "$1" ]; then
        echo "Usage: ./sops-helper.sh decrypt <file>"
        exit 1
    fi
    
    SOPS_AGE_KEY_FILE="$SOPS_KEY" sops -d "$1"
}

case "${1:-help}" in
    setup)
        cmd_setup
        ;;
    edit)
        cmd_edit
        ;;
    show-key|key)
        cmd_show_key
        ;;
    encrypt)
        cmd_encrypt "$2"
        ;;
    decrypt)
        cmd_decrypt "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac
