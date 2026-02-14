# Emacs Configuration

This directory contains the declarative Emacs configuration for this NixOS setup.

## Structure

- `init.el` - Main Emacs configuration file with core settings
- `early-init.el` - Early initialization for performance optimizations

## Features

The current configuration includes:

### Core Settings
- Clean UI (no menu bar, tool bar, or scroll bar)
- Line numbers for most modes
- Better defaults for indentation and backups
- UTF-8 encoding everywhere
- Auto-revert for files changed on disk

### Installed Packages

The following packages are installed via Nix (see `modules/home/emacs.nix`):

- **Evil Mode** - Vim emulation (optional - can be removed if you prefer default Emacs keybindings)
- **Which-key** - Shows available keybindings
- **Doom Themes & Modeline** - Modern UI appearance
- **Vertico/Marginalia/Consult** - Modern completion framework
- **Magit** - Git interface
- **LSP Mode** - Language Server Protocol support
- **Nix Mode** - Syntax highlighting and support for Nix files
- **Company** - Code completion
- **Flycheck** - Syntax checking
- **Projectile** - Project management
- And more...

## Customization

### Adding Packages

To add new Emacs packages, edit `modules/home/emacs.nix` and add them to the `extraPackages` list:

```nix
extraPackages = epkgs: with epkgs; [
  # ... existing packages ...
  your-new-package
];
```

### Modifying Configuration

Edit the files in this directory (`config/emacs/`):
- `init.el` - For general configuration
- `early-init.el` - For early startup optimizations

The configuration is automatically linked to `~/.emacs.d/` by Home Manager.

### Removing Evil Mode

If you prefer default Emacs keybindings instead of Vim-style bindings, remove these lines from `modules/home/emacs.nix`:

```nix
evil                # Vim emulation
evil-collection     # Evil bindings for various modes
```

## First Run

On first run, Emacs may need to:
1. Download and compile the packages (handled by Nix)
2. Build icon fonts (if you see empty boxes, run `M-x all-the-icons-install-fonts`)

## Further Configuration

You can extend this configuration by:
1. Adding new `.el` files in this directory
2. Sourcing them in `init.el` with `(load "~/.emacs.d/your-file.el")`
3. Adding the new files to `modules/home/emacs.nix` in the `home.file` section

## Resources

- [Emacs Manual](https://www.gnu.org/software/emacs/manual/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html#opt-programs.emacs.enable)
- [Evil Mode Documentation](https://github.com/emacs-evil/evil) (if using Evil)
