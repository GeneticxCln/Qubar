#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - SDDM Theme Setup
# ═══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global_functions.sh"

LOG="$LOG_DIR/install-$(date +%d-%H%M%S)_sddm-theme.log"

THEME_URL="https://github.com/JaKooLit/simple-sddm-2.git"
THEME_NAME="simple_sddm_2"

print_section "SDDM Theme Setup"

# Install SDDM if not present
install_package "sddm" "$LOG"
install_package "qt6-svg" "$LOG"
install_package "qt6-virtualkeyboard" "$LOG"

# Clone theme
echo -e "${NOTE} Downloading SDDM theme..."
cd /tmp

if [ -d "$THEME_NAME" ]; then
    rm -rf "$THEME_NAME"
fi

git clone --depth=1 "$THEME_URL" "$THEME_NAME" >> "$LOG" 2>&1 || {
    echo -e "${ERROR} Failed to clone theme"
    exit 1
}

# Remove existing theme
if [ -d "/usr/share/sddm/themes/$THEME_NAME" ]; then
    sudo rm -rf "/usr/share/sddm/themes/$THEME_NAME"
fi

# Install theme
sudo mkdir -p /usr/share/sddm/themes
sudo mv "$THEME_NAME" "/usr/share/sddm/themes/$THEME_NAME"
echo -e "${OK} Theme installed to /usr/share/sddm/themes/$THEME_NAME"

# Configure SDDM
SDDM_CONF="/etc/sddm.conf"

echo -e "${NOTE} Configuring SDDM..."

# Backup existing config
if [ -f "$SDDM_CONF" ]; then
    sudo cp "$SDDM_CONF" "${SDDM_CONF}.bak"
fi

# Create or update config
if grep -q '^\[Theme\]' "$SDDM_CONF" 2>/dev/null; then
    sudo sed -i "/^\[Theme\]/,/^\[/{s/^\s*Current=.*/Current=$THEME_NAME/}" "$SDDM_CONF"
else
    echo -e "\n[Theme]\nCurrent=$THEME_NAME" | sudo tee -a "$SDDM_CONF" > /dev/null
fi

# Add virtual keyboard
if ! grep -q '^\[General\]' "$SDDM_CONF" 2>/dev/null; then
    echo -e "\n[General]\nInputMethod=qtvirtualkeyboard" | sudo tee -a "$SDDM_CONF" > /dev/null
fi

# Copy wallpaper to theme
if [ -f "$HOME/Pictures/wallpapers/default.png" ]; then
    sudo cp "$HOME/Pictures/wallpapers/default.png" "/usr/share/sddm/themes/$THEME_NAME/Backgrounds/default"
    sudo sed -i 's|^wallpaper=".*"|wallpaper="Backgrounds/default"|' "/usr/share/sddm/themes/$THEME_NAME/theme.conf"
    echo -e "${OK} Set custom wallpaper for login screen"
fi

# Enable SDDM
echo -e "${NOTE} Enabling SDDM service..."
sudo systemctl enable sddm >> "$LOG" 2>&1

echo -e "${OK} SDDM theme configured!"
echo -e "${INFO} The theme will be applied on next login."
