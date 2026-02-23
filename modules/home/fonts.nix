{ pkgs, ... }:
{
    home.packages = with pkgs; [
        nerd-fonts.caskaydia-cove
        
        # UI fonts
        inter
        cantarell-fonts
        atkinson-hyperlegible-next
        
        # Common word processing fonts
        liberation_ttf  # Liberation Sans, Serif, Mono (MS Office compatible)
        dejavu_fonts    # DejaVu Sans, Serif, Mono
        noto-fonts      # Noto Sans, Serif
        noto-fonts-color-emoji
        (pkgs.google-fonts.override {
          fonts = [
            "Young Serif"
            "Source Sans 3"
            "Source Serif 4"
            "Merriweather"
            "EB Garamond"
            "Bitter"
          ];
        })
    ];

    fonts.fontconfig.enable = true;
}
