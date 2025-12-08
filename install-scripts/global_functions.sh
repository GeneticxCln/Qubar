#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - Global Installer Functions
# Adapted from JaKooLit's Arch-Hyprland scripts
# ═══════════════════════════════════════════════════════════

set -e

# Colors
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
ACTION="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
CYAN="$(tput setaf 6)"
RESET="$(tput sgr0)"

# Qubar branding
QUBAR_LOGO="
${MAGENTA}╔═══════════════════════════════════════════════════════╗
║                                                         ║
║     ██████╗ ██╗   ██╗██████╗  █████╗ ██████╗           ║
║    ██╔═══██╗██║   ██║██╔══██╗██╔══██╗██╔══██╗          ║
║    ██║   ██║██║   ██║██████╔╝███████║██████╔╝          ║
║    ██║▄▄ ██║██║   ██║██╔══██╗██╔══██║██╔══██╗          ║
║    ╚██████╔╝╚██████╔╝██████╔╝██║  ██║██║  ██║          ║
║     ╚══▀▀═╝  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝          ║
║                                                         ║
║         ${CYAN}Hyprland Desktop Environment${MAGENTA}                   ║
╚═══════════════════════════════════════════════════════╝${RESET}
"

# Directories
QUBAR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$QUBAR_DIR/install-logs"
mkdir -p "$LOG_DIR"

# ═══════════════════════════════════════════════════════════
# PROGRESS SPINNER
# ═══════════════════════════════════════════════════════════
show_progress() {
    local pid=$1
    local package_name=$2
    local spin=(
        "●○○○○○○○○○"
        "○●○○○○○○○○"
        "○○●○○○○○○○"
        "○○○●○○○○○○"
        "○○○○●○○○○○"
        "○○○○○●○○○○"
        "○○○○○○●○○○"
        "○○○○○○○●○○"
        "○○○○○○○○●○"
        "○○○○○○○○○●"
    )
    local i=0

    tput civis  # Hide cursor
    printf "\r${NOTE} Installing ${YELLOW}%s${RESET} ..." "$package_name"

    while ps -p $pid &>/dev/null; do
        printf "\r${NOTE} Installing ${YELLOW}%s${RESET} %s" "$package_name" "${spin[i]}"
        i=$(( (i + 1) % 10 ))
        sleep 0.2
    done

    printf "\r${OK} Installed ${YELLOW}%s${RESET}%-20s\n" "$package_name" ""
    tput cnorm  # Show cursor
}

# ═══════════════════════════════════════════════════════════
# PACKAGE INSTALLATION
# ═══════════════════════════════════════════════════════════

# Detect AUR helper
detect_aur_helper() {
    if command -v yay &>/dev/null; then
        echo "yay"
    elif command -v paru &>/dev/null; then
        echo "paru"
    else
        echo ""
    fi
}

ISAUR=$(detect_aur_helper)

# Install package with pacman
install_package_pacman() {
    local pkg="$1"
    local log="$2"
    
    if pacman -Q "$pkg" &>/dev/null; then
        echo -e "${INFO} ${MAGENTA}$pkg${RESET} is already installed. Skipping..."
        return 0
    fi
    
    (
        stdbuf -oL sudo pacman -S --noconfirm "$pkg" 2>&1
    ) >> "$log" 2>&1 &
    
    local PID=$!
    show_progress $PID "$pkg"
    
    if pacman -Q "$pkg" &>/dev/null; then
        return 0
    else
        echo -e "${ERROR} ${YELLOW}$pkg${RESET} failed to install. Check $log"
        return 1
    fi
}

# Install package with AUR helper
install_package() {
    local pkg="$1"
    local log="$2"
    
    if [ -z "$ISAUR" ]; then
        echo -e "${ERROR} No AUR helper found. Please install yay or paru first."
        return 1
    fi
    
    if $ISAUR -Q "$pkg" &>/dev/null; then
        echo -e "${INFO} ${MAGENTA}$pkg${RESET} is already installed. Skipping..."
        return 0
    fi
    
    (
        stdbuf -oL $ISAUR -S --noconfirm "$pkg" 2>&1
    ) >> "$log" 2>&1 &
    
    local PID=$!
    show_progress $PID "$pkg"
    
    if $ISAUR -Q "$pkg" &>/dev/null; then
        return 0
    else
        echo -e "${ERROR} ${YELLOW}$pkg${RESET} failed to install. Check $log"
        return 1
    fi
}

# Install multiple packages
install_packages() {
    local log="$1"
    shift
    local packages=("$@")
    
    for pkg in "${packages[@]}"; do
        install_package "$pkg" "$log"
    done
}

# ═══════════════════════════════════════════════════════════
# FILE OPERATIONS
# ═══════════════════════════════════════════════════════════

# Backup and copy file
backup_and_copy() {
    local src="$1"
    local dest="$2"
    
    if [ -f "$dest" ]; then
        cp "$dest" "${dest}.bak.$(date +%Y%m%d_%H%M%S)"
        echo -e "${INFO} Backed up ${YELLOW}$dest${RESET}"
    fi
    
    cp "$src" "$dest"
    echo -e "${OK} Copied to ${YELLOW}$dest${RESET}"
}

# Create directory if not exists
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${OK} Created directory ${YELLOW}$dir${RESET}"
    fi
}

# ═══════════════════════════════════════════════════════════
# SYSTEMD HELPERS
# ═══════════════════════════════════════════════════════════

# Create and enable user service
create_user_service() {
    local name="$1"
    local exec_path="$2"
    local description="$3"
    
    local service_dir="$HOME/.config/systemd/user"
    ensure_dir "$service_dir"
    
    cat > "$service_dir/${name}.service" << EOF
[Unit]
Description=$description
After=graphical-session.target

[Service]
Type=simple
ExecStart=$exec_path
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable "${name}.service" 2>/dev/null
    systemctl --user start "${name}.service" 2>/dev/null
    
    echo -e "${OK} Created and enabled ${YELLOW}${name}${RESET} service"
}

# ═══════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════

# Ask yes/no question
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -rp "$prompt" response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Print section header
print_section() {
    local title="$1"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${CYAN}  $title${RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
}

# Print logo
print_logo() {
    echo -e "$QUBAR_LOGO"
}

# Check if running as root
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${ERROR} Do not run this script as root!"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}
