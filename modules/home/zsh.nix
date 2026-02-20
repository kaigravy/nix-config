{ config, ... }:

let
  configDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    completionInit = ''
      autoload -Uz compinit && compinit
      zstyle ':completion:*' menu select          # navigable menu on Tab
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive
      zstyle ':completion:*' list-colors ''       # coloured completions
    '';
    
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

    # Plugins
    plugins = [
    ];

    # Additional init commands
    initExtra = ''
      # Menu-select navigation (arrow keys, Enter to confirm)
      zmodload zsh/complist
      bindkey -M menuselect '^[[A' up-line-or-history    # up arrow
      bindkey -M menuselect '^[[B' down-line-or-history  # down arrow
      bindkey -M menuselect '^[[D' backward-char         # left arrow
      bindkey -M menuselect '^[[C' forward-char          # right arrow
      bindkey -M menuselect '^M'   .accept-line          # Enter accepts & runs
      
      # Better history search with arrow keys
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward
      
      # Set editor
      export EDITOR="emacs"
      export VISUAL="emacs"
      
      # Add Doom Emacs to PATH (using actual evict config path)
      export PATH="${configDir}/emacs/bin:$PATH"
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zoxide - smarter cd command
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      #"--cmd cd"  # Use 'cd' instead of 'z' for familiarity
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
