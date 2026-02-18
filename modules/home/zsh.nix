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

    # Plugins - load autocomplete first
    plugins = [
      {
        name = "zsh-autocomplete";
        src = pkgs.zsh-autocomplete;
        file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
      }
    ];

    # Additional init commands - load spaceship AFTER everything else
    initExtra = ''
      # Better history search with arrow keys
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward
      
      # Set editor
      export EDITOR="emacs"
      export VISUAL="emacs"
      
      # Add Doom Emacs to PATH (using actual evict config path)
      export PATH="${configDir}/emacs/bin:$PATH"
      
      # Load spaceship prompt last
      source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
      spaceship_vi_mode_enable
    '';
  };

  # Zoxide - smarter cd command
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"  # Use 'cd' instead of 'z' for familiarity
    ];
  };

  # Persist zoxide database so it remembers directory usage across reboots
  home.persistence."/persist" = {
    directories = [
      "${config.home.evict.configDirName}/zoxide"
    ];
  };

  # Store zoxide data in config dir
  home.sessionVariables = {
    _ZO_DATA_DIR = "${configDir}/zoxide";
  };
}
