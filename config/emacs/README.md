# Doom Emacs Configuration

This directory contains the declarative Doom Emacs configuration for this NixOS setup.

## Structure

- `doom/init.el` - Doom modules configuration (which features to enable)
- `doom/config.el` - Your personal configuration
- `doom/packages.el` - Additional packages to install

## What is Doom Emacs?

Doom Emacs is a configuration framework for Emacs that provides:
- Pre-configured modules for various languages and tools
- Vim keybindings (Evil mode) by default
- Modern, fast UI with sensible defaults
- Extensive package ecosystem
- Great documentation

## Installation Location

- **Doom install**: `/users/kai/home/.emacs.d/` (persistent)
- **Doom config**: `/users/kai/config/doom/` (ephemeral, generated from flake)
- **Doom data**: `/users/kai/home/.local/share/doom/` (persistent)

## First Run

After rebuilding your system:

```bash
sudo nixos-rebuild switch --flake /workspaces/nix-config#vm
```

The first time, Doom will automatically:
1. Clone the Doom Emacs repository
2. Install all configured packages
3. Compile everything for fast startup

Then you can launch Emacs with:
```bash
emacs
```

Or use the Doom CLI:
```bash
doom doctor    # Check for issues
doom sync      # Update packages
doom upgrade   # Upgrade Doom itself
```

## Key Features Enabled

The current configuration includes:

- **Completion**: Vertico (modern completion UI)
- **UI**: Doom dashboard, modeline, treemacs, workspaces
- **Editor**: Evil (Vim bindings), snippets, multiple-cursors
- **Tools**: LSP, Magit, tree-sitter
- **Languages**: Nix, JavaScript, Markdown, YAML, JSON, Emacs Lisp, Shell, Org
- **Terminal**: vterm (best terminal emulator for Emacs)

## Customization

### Enabling/Disabling Modules

Edit `doom/init.el` to enable or disable Doom modules. Uncomment lines to enable features:

```elisp
:lang
(python +lsp)    ; Enable Python with LSP support
(rust +lsp)      ; Enable Rust with LSP support
```

### Personal Configuration

Edit `doom/config.el` for your personal settings:
- Theme selection
- Keybindings
- Package configuration

### Installing Packages

Edit `doom/packages.el` to install additional packages:

```elisp
(package! some-package)
```

### Applying Changes

After editing any Doom config files, rebuild your system:

```bash
sudo nixos-rebuild switch --flake /workspaces/nix-config#vm
```

Doom will automatically sync packages on the next activation.

## Keybindings

Doom uses Vim-style keybindings by default:

- `SPC` - Leader key for most commands
- `SPC f f` - Find file
- `SPC f r` - Recent files
- `SPC b b` - Switch buffer
- `SPC p p` - Switch project
- `SPC g g` - Magit status
- `SPC h d h` - Describe key
- `SPC h d v` - Describe variable

Press `SPC ?` to see all available keybindings.

## Resources

- [Doom Emacs Documentation](https://github.com/doomemacs/doomemacs/tree/master/docs)
- [Doom Emacs Discourse](https://discourse.doomemacs.org/)
- [Module Documentation](https://github.com/doomemacs/doomemacs/tree/master/modules)

