# Doom Emacs Configuration

This directory contains the declarative Doom Emacs configuration for this NixOS setup.

## Structure

- `doom/init.el` - Doom modules configuration (which features to enable)
- `doom/config.el` - Your personal configuration
- `doom/packages.el` - Additional packages to install

## How it works

- **Emacs** is installed via Nix (see `modules/home/emacs.nix`)
- **Doom config** (`doom/` directory) is symlinked to `~/.config/doom` (or `/users/kai/config/doom` with evict)
- **Doom itself** (`~/.config/emacs`) is persisted across reboots using impermanence
- Doom manages its own packages and installation declaratively through its own config files

## Installation Location

- **Doom install**: `~/.config/emacs` (persistent via impermanence)
- **Doom config**: `/users/kai/config/doom/` (symlinked from this repo)
- **Doom data**: `~/.local/share/doom/` (created by Doom)

## First-time setup

After rebuilding your NixOS configuration:

1. Install Doom Emacs:
   ```bash
   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
   ~/.config/emacs/bin/doom install
   ```

2. Add Doom's bin to your PATH (optional, for CLI tools):
   ```bash
   export PATH="$HOME/.config/emacs/bin:$PATH"
   ```

## Making changes

1. Edit config files in this repo (`config/emacs/doom/`)
2. Commit and rebuild your NixOS config to sync changes to `~/.config/doom`
3. Run `doom sync` to apply changes to Doom
4. Restart Emacs or run `M-x doom/reload` inside Emacs

## Useful Doom Commands

```bash
doom doctor    # Check for issues
doom sync      # Sync packages after config changes
doom upgrade   # Upgrade Doom itself
doom build     # Rebuild Doom
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

