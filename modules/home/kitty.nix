{ pkgs, ... }:

{
  # Install Kitty and Cascadia Code Nerd Font
  home.packages = with pkgs; [
    kitty
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
  ];

  # Link the Kitty config file
  xdg.configFile."kitty/kitty.conf" = {
    source = ../../config/kitty/kitty.conf;
  };
}
