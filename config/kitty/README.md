# Kitty Terminal Configuration

This directory contains the Kitty terminal emulator configuration.

## Font

The configuration uses **Cascadia Code Nerd Font** with ligatures enabled. The Nerd Font variant includes:
- Programming ligatures for better code readability
- Powerline symbols
- Additional glyphs and icons

## Features

- **Ligatures**: Enabled by default, disabled when cursor is over them for easier editing
- **Color Scheme**: Doom One inspired theme matching the Emacs configuration
- **Performance**: Optimized repaint and input delay settings
- **Tab Bar**: Powerline style with slanted separators
- **Shell Integration**: Enabled for better terminal features

## Customization

Edit `kitty.conf` to customize:
- Font size and family
- Color scheme
- Key bindings
- Window padding and layout
- Tab bar style

After making changes, reload Kitty with `Ctrl+Shift+F5` or restart the terminal.

## Font Installation

The Cascadia Code Nerd Font is automatically installed via the Nix configuration in `modules/home/kitty.nix`.
