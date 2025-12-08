#!/bin/bash
# ╔═══════════════════════════════════════════════════════════╗
# ║                  QUBAR AUTO-INSTALLER                     ║
# ║          Automated setup for Qubar Desktop Environment    ║
# ╚═══════════════════════════════════════════════════════════╝

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ═══════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if running on Arch Linux
check_distro() {
    if [ ! -f /etc/arch-release ]; then
        print_error "This installer is currently only for Arch Linux"
        print_info "Detected distro: $(cat /etc/os-release | grep '^NAME=' | cut -d'=' -f2)"
        exit 1
    fi
    print_success "Arch Linux detected"
}

# Check for existing configs
check_existing_configs() {
    local has_existing=false
    
    if [ -d "$HOME/.config/quickshell" ]; then
        print_warning "Existing QuickShell config found at ~/.config/quickshell"
        has_existing=true
    fi
    
    if [ -d "$HOME/.config/hypr" ]; then
        print_warning "Existing Hyprland config found at ~/.config/hypr"
        has_existing=true
    fi
    
    if [ "$has_existing" = true ]; then
        echo ""
        read -p "Do you want to backup existing configs before proceeding? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Creating backup..."
            if [ -f "$SCRIPT_DIR/scripts/backup-config.sh" ]; then
                bash "$SCRIPT_DIR/scripts/backup-config.sh"
            else
                # Manual backup if script doesn't exist
                BACKUP_DIR="$HOME/qubar-backups"
                TIMESTAMP=$(date +%Y%m%d-%H%M%S)
                mkdir -p "$BACKUP_DIR"
                [ -d "$HOME/.config/quickshell" ] && cp -r "$HOME/.config/quickshell" "$BACKUP_DIR/quickshell-$TIMESTAMP"
                [ -d "$HOME/.config/hypr" ] && cp -r "$HOME/.config/hypr" "$BACKUP_DIR/hypr-$TIMESTAMP"
                print_success "Backup created in $BACKUP_DIR"
            fi
        fi
        
        echo ""
        read -p "Continue with installation? This will OVERWRITE existing configs (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
}

# Install dependencies
install_dependencies() {
    print_header "Installing Dependencies"
    
    # Core dependencies
    local CORE_DEPS=(
        "hyprland"
        "quickshell"
        "qt6-declarative"
        "qt6-svg"
    )
    
    # System tools
    local SYSTEM_DEPS=(
        "wpctl"
        "brightnessctl"
        "networkmanager"
        "bluez-utils"
        "playerctl"
    )
    
    # Wayland tools
    local WAYLAND_DEPS=(
        "xdg-desktop-portal-hyprland"
        "xdg-desktop-portal-gtk"
        "hyprpaper"
        "swaylock-effects"
        "hyprshot"
    )
    
    # Optional but recommended
    local OPTIONAL_DEPS=(
        "sddm"
        "dunst"
        "polkit-kde-agent"
    )
    
    # Combine all deps
    local ALL_DEPS=("${CORE_DEPS[@]}" "${SYSTEM_DEPS[@]}" "${WAYLAND_DEPS[@]}" "${OPTIONAL_DEPS[@]}")
    
    echo "The following packages will be installed:"
    printf '  - %s\n' "${ALL_DEPS[@]}"
    echo ""
    
    read -p "Proceed with installation? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Skipping dependency installation"
        print_warning "Some features may not work without required packages"
        return
    fi
    
    print_info "Installing packages via pacman..."
    sudo pacman -S --needed --noconfirm "${ALL_DEPS[@]}"
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Some packages failed to install"
        print_warning "Continuing anyway..."
    fi
}

# Deploy configs
deploy_configs() {
    print_header "Deploying Configurations"
    
    # Create necessary directories
    mkdir -p "$HOME/.config/quickshell"
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/swaylock"
    mkdir -p "$HOME/.config/xdg-desktop-portal"
    
    # Copy QuickShell configs
    print_info "Copying QuickShell configs..."
    cp -r "$SCRIPT_DIR"/!(hypr|hyprland.conf|.git|wallpapers|scripts|docs|.config|install*.sh|sddm.conf|README.md|LICENSE|*.rules|*.json|*.qml|plan) "$HOME/.config/quickshell/" 2>/dev/null || true
    
    # Copy main QML files
    if [ -f "$SCRIPT_DIR/shell.qml" ]; then
        cp -r "$SCRIPT_DIR"/*.qml "$HOME/.config/quickshell/" 2>/dev/null || true
    fi
    
    # Copy all module directories
    for dir in backend topbar panel launcher overview theme modules services; do
        if [ -d "$SCRIPT_DIR/$dir" ]; then
            cp -r "$SCRIPT_DIR/$dir" "$HOME/.config/quickshell/" 2>/dev/null || true
        fi
    done
    
    print_success "QuickShell configs deployed"
    
    # Copy Hyprland config (modular)
    print_info "Copying Hyprland config..."
    if [ -f "$SCRIPT_DIR/hypr/qubar.conf" ]; then
        cp "$SCRIPT_DIR/hypr/qubar.conf" "$HOME/.config/hypr/hyprland.conf"
        cp -r "$SCRIPT_DIR/hypr/modules" "$HOME/.config/hypr/" 2>/dev/null || true
        cp -r "$SCRIPT_DIR/hypr/user" "$HOME/.config/hypr/" 2>/dev/null || true
    elif [ -f "$SCRIPT_DIR/hyprland.conf" ]; then
        # Fallback to old single file
        cp "$SCRIPT_DIR/hyprland.conf" "$HOME/.config/hypr/"
    fi
    print_success "Hyprland config deployed"
    
    # Copy Swaylock config
    if [ -d "$SCRIPT_DIR/.config/swaylock" ]; then
        print_info "Copying Swaylock config..."
        cp -r "$SCRIPT_DIR/.config/swaylock"/* "$HOME/.config/swaylock/" 2>/dev/null || true
        print_success "Swaylock config deployed"
    fi
    
    # Copy XDG portal config
    if [ -d "$SCRIPT_DIR/.config/xdg-desktop-portal" ]; then
        print_info "Copying XDG portal config..."
        cp -r "$SCRIPT_DIR/.config/xdg-desktop-portal"/* "$HOME/.config/xdg-desktop-portal/" 2>/dev/null || true
        print_success "XDG portal config deployed"
    fi
    
    # Copy wallpapers (if they exist and user wants them)
    if [ -d "$SCRIPT_DIR/wallpapers" ]; then
        echo ""
        read -p "Copy wallpapers? (~1.1GB) (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Copying wallpapers (this may take a while)..."
            mkdir -p "$HOME/Qubar/wallpapers"
            cp -r "$SCRIPT_DIR/wallpapers"/* "$HOME/Qubar/wallpapers/" 2>/dev/null || true
            print_success "Wallpapers copied"
        fi
    fi
    
    # Copy scripts
    if [ -d "$SCRIPT_DIR/scripts" ]; then
        print_info "Copying scripts..."
        mkdir -p "$HOME/Qubar/scripts"
        cp -r "$SCRIPT_DIR/scripts"/* "$HOME/Qubar/scripts/" 2>/dev/null || true
        chmod +x "$HOME/Qubar/scripts"/*.sh 2>/dev/null || true
        print_success "Scripts deployed"
    fi
}

# SDDM setup
setup_sddm() {
    echo ""
    read -p "Install SDDM login manager? (requires sudo) (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$SCRIPT_DIR/install-sddm-theme.sh" ]; then
            print_info "Running SDDM installer..."
            sudo bash "$SCRIPT_DIR/install-sddm-theme.sh"
        else
            print_warning "SDDM installer script not found, skipping"
        fi
    fi
}

# Post-install setup
post_install() {
    print_header "Post-Installation Setup"
    
    # Set initial wallpaper
    if [ -f "$HOME/Qubar/scripts/set-wallpaper.sh" ] && [ -d "$HOME/Qubar/wallpapers" ]; then
        print_info "Setting initial wallpaper..."
        bash "$HOME/Qubar/scripts/set-wallpaper.sh" random 2>/dev/null || true
    fi
    
    print_success "Post-install complete"
}

# ═══════════════════════════════════════════════════════════
# MAIN INSTALLATION
# ═══════════════════════════════════════════════════════════

main() {
    clear
    print_header "Qubar Desktop Environment Installer"
    echo ""
    echo "This script will install Qubar, a QuickShell-based"
    echo "desktop environment for Hyprland."
    echo ""
    
    # Run checks
    check_distro
    check_existing_configs
    
    # Install
    echo ""
    install_dependencies
    echo ""
    deploy_configs
    echo ""
    setup_sddm
    echo ""
    post_install
    
    # Success message
    echo ""
    print_header "Installation Complete!"
    echo ""
    print_success "Qubar has been installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Review configs in ~/.config/quickshell and ~/.config/hypr"
    echo "  2. Customize user overrides in ~/.config/hypr/user/"
    echo "  3. Start Hyprland: 'Hyprland' or reboot if using SDDM"
    echo ""
    echo "Useful commands:"
    echo "  - Backup configs: ~/Qubar/scripts/backup-config.sh"
    echo "  - Change wallpaper: ~/Qubar/scripts/set-wallpaper.sh random"
    echo ""
    echo "Documentation: https://github.com/GeneticxCln/Qubar"
    echo ""
    
    read -p "Start Hyprland now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Starting Hyprland..."
        exec Hyprland
    fi
}

# Run main function
main
