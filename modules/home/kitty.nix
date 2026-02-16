{ pkgs, ... }:

{
  # Install Kitty
  home.packages = with pkgs; [
    kitty
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
  ];

  # Enable fontconfig
  fonts.fontconfig.enable = true;

  # Link the Kitty config file
  xdg.configFile."kitty/kitty.conf" = {
    source = ../../config/kitty/kitty.conf;
  };
}
