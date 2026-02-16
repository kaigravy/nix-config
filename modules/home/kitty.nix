{ pkgs, ... }:

{
  # Install Kitty and Cascadia Code Nerd Font
  home.packages = with pkgs; [
    kitty
    cascadia-code
  ];

  # Link the Kitty config file
  xdg.configFile."kitty/kitty.conf" = {
    source = ../../config/kitty/kitty.conf;
  };
}
