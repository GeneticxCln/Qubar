#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - Main Installer
# Complete installation script for Qubar desktop environment
# ═══════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source global functions
if [ -f "$SCRIPT_DIR/install-scripts/global_functions.sh" ]; then
    source "$SCRIPT_DIR/install-scripts/global_functions.sh"
else
    echo "Error: global_functions.sh not found!"
    exit 1
fi

# ═══════════════════════════════════════════════════════════
# PACKAGE LISTS
# ═══════════════════════════════════════════════════════════

core_pkgs=(
    hyprland
    hyprpaper
    hyprlock
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit-kde-agent
)

shell_pkgs=(
    qt6-declarative
    qt6-5compat
    quickshell-git
)

system_pkgs=(
    brightnessctl
    gammastep
    wlogout
    wallust
    pipewire
    wireplumber
    libnotify
    grim
    slurp
    swappy
)

apps_pkgs=(
    kitty
    thunar
    thunar-archive-plugin
    firefox
    cava
)

fonts_pkgs=(
    ttf-jetbrains-mono-nerd
    ttf-font-awesome
    noto-fonts
    noto-fonts-emoji
)

optional_pkgs=(
    swaylock
    wl-clipboard
    cliphist
    pamixer
    playerctl
)

# ═══════════════════════════════════════════════════════════
# MAIN INSTALLATION
# ═══════════════════════════════════════════════════════════

main() {
    check_not_root
    print_logo
    
    echo -e "${INFO} Welcome to the ${MAGENTA}Qubar${RESET} installer!"
    echo -e "${INFO} This will install and configure your Hyprland desktop."
    echo ""
    
    # Check for AUR helper
    if [ -z "$ISAUR" ]; then
        echo -e "${WARN} No AUR helper found!"
        if ask_yes_no "Would you like to install yay?"; then
            install_yay
        else
            echo -e "${ERROR} An AUR helper is required. Exiting."
            exit 1
        fi
    fi
    
    echo -e "${INFO} Using AUR helper: ${YELLOW}$ISAUR${RESET}"
    echo ""
    
    # Component selection
    INSTALL_NVIDIA=false
    INSTALL_MONITORS=false
    INSTALL_ZSH=false
    
    if ask_yes_no "Install NVIDIA drivers?" "n"; then
        INSTALL_NVIDIA=true
    fi
    
    if ask_yes_no "Install system monitors (battery, temp, disk)?" "y"; then
        INSTALL_MONITORS=true
    fi
    
    if ask_yes_no "Install ZSH with Oh My Zsh?" "n"; then
        INSTALL_ZSH=true
    fi
    
    echo ""
    echo -e "${ACTION} Starting installation..."
    echo ""
    
    LOG="$LOG_DIR/install-$(date +%Y%m%d_%H%M%S).log"
    
    # Install packages
    print_section "Core Packages"
    install_packages "$LOG" "${core_pkgs[@]}"
    
    print_section "QuickShell"
    install_packages "$LOG" "${shell_pkgs[@]}"
    
    print_section "System Utilities"
    install_packages "$LOG" "${system_pkgs[@]}"
    
    print_section "Applications"
    install_packages "$LOG" "${apps_pkgs[@]}"
    
    print_section "Fonts"
    install_packages "$LOG" "${fonts_pkgs[@]}"
    
    print_section "Optional Tools"
    install_packages "$LOG" "${optional_pkgs[@]}"
    
    # NVIDIA setup
    if [ "$INSTALL_NVIDIA" = true ]; then
        bash "$SCRIPT_DIR/install-scripts/nvidia.sh"
    fi
    
    # System monitors
    if [ "$INSTALL_MONITORS" = true ]; then
        bash "$SCRIPT_DIR/install-scripts/battery-monitor.sh"
        bash "$SCRIPT_DIR/install-scripts/temp-monitor.sh"
        bash "$SCRIPT_DIR/install-scripts/disk-monitor.sh"
    fi
    
    # ZSH setup
    if [ "$INSTALL_ZSH" = true ]; then
        bash "$SCRIPT_DIR/install-scripts/zsh.sh"
    fi
    
    # Copy dotfiles
    print_section "Copying Configuration Files"
    copy_dotfiles
    
    # Setup SDDM theme
    print_section "SDDM Theme"
    if ask_yes_no "Setup SDDM login theme?" "y"; then
        bash "$SCRIPT_DIR/install-scripts/sddm-theme.sh"
    fi
    
    # Final steps
    print_section "Installation Complete!"
    
    echo -e "${OK} Qubar has been installed successfully!"
    echo ""
    echo -e "${INFO} Configuration files copied to:"
    echo -e "    ${YELLOW}~/.config/quickshell${RESET}"
    echo -e "    ${YELLOW}~/.config/hypr${RESET}"
    echo -e "    ${YELLOW}~/.config/kitty${RESET}"
    echo ""
    echo -e "${INFO} To start Hyprland, log out and select it from your login manager."
    echo -e "${INFO} Or run: ${YELLOW}Hyprland${RESET}"
    echo ""
    
    if [ "$INSTALL_NVIDIA" = true ]; then
        echo -e "${WARN} Please ${YELLOW}reboot${RESET} for NVIDIA drivers to take effect!"
    fi
    
    echo -e "${INFO} Check logs at: ${YELLOW}$LOG_DIR${RESET}"
    echo ""
    echo -e "${MAGENTA}Thank you for using Qubar! 🚀${RESET}"
}

# ═══════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════

install_yay() {
    echo -e "${NOTE} Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
    
    ISAUR="yay"
    echo -e "${OK} yay installed successfully!"
}

copy_dotfiles() {
    # Create directories
    ensure_dir "$HOME/.config/quickshell"
    ensure_dir "$HOME/.config/hypr"
    ensure_dir "$HOME/.config/kitty"
    ensure_dir "$HOME/.config/cava"
    ensure_dir "$HOME/.config/Thunar"
    ensure_dir "$HOME/.config/wlogout"
    
    # Copy QuickShell config
    if [ -d "$SCRIPT_DIR/backend" ]; then
        cp -r "$SCRIPT_DIR/backend" "$HOME/.config/quickshell/"
        cp -r "$SCRIPT_DIR/topbar" "$HOME/.config/quickshell/"
        cp -r "$SCRIPT_DIR/launcher" "$HOME/.config/quickshell/"
        cp -r "$SCRIPT_DIR/panel" "$HOME/.config/quickshell/"
        cp -r "$SCRIPT_DIR/theme" "$HOME/.config/quickshell/"
        cp -r "$SCRIPT_DIR/modules" "$HOME/.config/quickshell/"
        cp "$SCRIPT_DIR/shell.qml" "$HOME/.config/quickshell/"
        echo -e "${OK} Copied QuickShell configuration"
    fi
    
    # Copy Hyprland config
    if [ -d "$SCRIPT_DIR/hypr" ]; then
        cp -r "$SCRIPT_DIR/hypr/"* "$HOME/.config/hypr/"
        echo -e "${OK} Copied Hyprland configuration"
    fi
    
    # Copy app configs
    if [ -d "$SCRIPT_DIR/.config" ]; then
        cp -r "$SCRIPT_DIR/.config/kitty/"* "$HOME/.config/kitty/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/.config/cava/"* "$HOME/.config/cava/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/.config/Thunar/"* "$HOME/.config/Thunar/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/.config/wlogout/"* "$HOME/.config/wlogout/" 2>/dev/null || true
        echo -e "${OK} Copied application configurations"
    fi
    
    # Copy scripts
    if [ -d "$SCRIPT_DIR/scripts" ]; then
        ensure_dir "$HOME/.config/qubar/scripts"
        cp -r "$SCRIPT_DIR/scripts/"* "$HOME/.config/qubar/scripts/"
        chmod +x "$HOME/.config/qubar/scripts/"*.sh
        echo -e "${OK} Copied utility scripts"
    fi
    
    # Copy wallpapers
    if [ -d "$SCRIPT_DIR/wallpapers" ]; then
        ensure_dir "$HOME/Pictures/wallpapers"
        cp -r "$SCRIPT_DIR/wallpapers/"* "$HOME/Pictures/wallpapers/"
        echo -e "${OK} Copied wallpapers"
    fi
}

# Run main
main "$@"
