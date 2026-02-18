{ pkgs, ... }:

{
  # Install Kitty
  home.packages = with pkgs; [
    kitty
  ];

  # Link the Kitty config file
  xdg.configFile."kitty/kitty.conf" = {
    source = ../../config/kitty/kitty.conf;
  };
}
