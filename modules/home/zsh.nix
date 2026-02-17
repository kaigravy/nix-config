{ config, pkgs, ... }:

let
  configDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Don't set dotDir - we're managing paths explicitly via evict
    # zsh will use the default ~/.zshrc location
    
    # History settings
    history = {
      size = 10000;
      path = "${configDir}/zsh/history";
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    # Shell aliases
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lah";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "grep --color=auto";
      df = "df -h";
      du = "du -h";
      
      # NixOS specific
      #rebuild = "sudo nixos-rebuild switch --flake /workspaces/nix-config#vm";
      #update = "cd /workspaces/nix-config && nix flake update && sudo nixos-rebuild switch --flake .#vm";
    };

    # Oh-My-Zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "command-not-found"
        "dirhistory"
      ];
      # Spaceship theme is installed separately below
    };

    # Additional init commands
    initExtra = ''
      # Better history search with arrow keys
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward
      
      # Set editor
      export EDITOR="emacs"
      export VISUAL="emacs"
      
      # Add Doom Emacs to PATH (using actual evict config path)
      export PATH="${configDir}/emacs/bin:$PATH"
      
      # Spaceship prompt configuration
      source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
      autoload -U promptinit; promptinit
      prompt spaceship
    '';
  };

  # Set XDG_CONFIG_HOME for evict's config directory
  home.sessionVariables = {
    XDG_CONFIG_HOME = configDir;
  };

  # Tell systemd where to find user services with evict
  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = configDir;
  };

  # Symlink .config to config so systemd can find user services
  # Systemd looks in ~/.config even when XDG_CONFIG_HOME is set differently
  home.file.".config".source = config.lib.file.mkOutOfStoreSymlink configDir;
  
  # Install spaceship prompt
  home.packages = with pkgs; [
    spaceship-prompt
  ];
}
