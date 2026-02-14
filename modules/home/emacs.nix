{ pkgs, config, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-gtk3;
    
    # Additional Emacs packages from nixpkgs
    extraPackages = epkgs: with epkgs; [
      # Essential packages
      use-package
      evil                # Vim emulation (optional, remove if you prefer default Emacs keybindings)
      evil-collection     # Evil bindings for various modes
      
      # UI enhancements
      which-key          # Show available keybindings
      doom-themes        # Modern themes
      doom-modeline      # Modern mode-line
      all-the-icons      # Icons for various UI elements
      
      # Completion framework
      vertico            # Vertical completion UI
      marginalia         # Rich annotations in minibuffer
      consult            # Useful search and navigation commands
      orderless          # Flexible completion style
      embark             # Context actions
      embark-consult     # Integration between embark and consult
      
      # Programming
      magit              # Git interface
      projectile         # Project management
      company            # Code completion
      flycheck           # Syntax checking
      lsp-mode           # Language Server Protocol support
      lsp-ui             # UI components for LSP
      
      # Language support
      nix-mode           # Nix language support
      markdown-mode      # Markdown support
      yaml-mode          # YAML support
      json-mode          # JSON support
      
      # Org mode (already included in Emacs, but these are extras)
      org-bullets        # Better org-mode bullets
      
      # Utilities
      rainbow-delimiters # Colorize nested delimiters
      undo-tree          # Better undo system
    ];
  };

  # XDG configuration for Emacs - ephemeral, regenerated from flake
  xdg.configFile = {
    "emacs/init.el" = {
      source = ../../config/emacs/init.el;
    };
    
    "emacs/early-init.el" = {
      source = ../../config/emacs/early-init.el;
    };
  };
}
