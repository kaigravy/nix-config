{ pkgs, config, ... }:

let
  emacsDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}/emacs";
in
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

  # Set Emacs to use the config directory via environment variable
  home.sessionVariables = {
    EMACS_USER_DIRECTORY = emacsDir;
  };

  # Link config files to the persistent config location
  home.file = {
    "${config.home.evict.configDirName}/emacs/init.el" = {
      source = ../../config/emacs/init.el;
    };
    
    "${config.home.evict.configDirName}/emacs/early-init.el" = {
      source = ../../config/emacs/early-init.el;
    };
  };

  # Ensure directories exist for Emacs in the persistent location
  home.activation.emacsDirectories = config.lib.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${emacsDir}/{backups,auto-save}
  '';
}
