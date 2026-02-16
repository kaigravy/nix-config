{ pkgs, config, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "CaskaydiaCove Nerd Font Mono";
      size = 12;
    };
  };

  # Install Cascadia Code Nerd Font
  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  # Link the Kitty config file
  xdg.configFile."kitty/kitty.conf" = {
    source = ../../config/kitty/kitty.conf;
  };
}
