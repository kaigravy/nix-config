{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    sops
    age
  ];

  shellHook = ''
    echo "=== SOPS Secret Management Environment ==="
    echo
    echo "Available commands:"
    echo "  age-keygen  - Generate age encryption keys"
    echo "  sops        - Edit/encrypt/decrypt secrets"
    echo
    echo "Key file: /persist/sops/age-keys.txt"
    echo "Secrets:  secrets.yaml"
    echo
    export SOPS_AGE_KEY_FILE="/persist/sops/age-keys.txt"
  '';
}
