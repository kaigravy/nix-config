{ pkgs, ... }:

{
  # Install Kitty
  home.packages = with pkgs; [
    kitty
    nerd-fonts.caskaydia-cove
  ];

  # Enable fontconfig
  fonts.fontconfig.enable = true;

  # Link the Kitty config file
  xdg.configFile."kitty/kitty.conf" = {
    source = ../../config/kitty/kitty.conf;
  };
}
