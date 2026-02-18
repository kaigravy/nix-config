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
    ];

    fonts.fontconfig.enable = true;
}