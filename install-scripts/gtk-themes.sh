#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - GTK Theme & Icon Setup
# ═══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global_functions.sh"

LOG="$LOG_DIR/install-$(date +%d-%H%M%S)_gtk-themes.log"

print_section "GTK Theme & Icon Setup"

# Required packages
theme_pkgs=(
    gtk3
    gtk4
    gsettings-desktop-schemas
    unzip
)

echo -e "${NOTE} Installing theme packages..."
for pkg in "${theme_pkgs[@]}"; do
    install_package "$pkg" "$LOG"
done

# Create theme directories
THEMES_DIR="$HOME/.local/share/themes"
ICONS_DIR="$HOME/.local/share/icons"
ensure_dir "$THEMES_DIR"
ensure_dir "$ICONS_DIR"

# Extract GTK themes
echo -e "${NOTE} Installing GTK themes..."
ASSETS_DIR="$QUBAR_DIR/assets"

if [ -f "$ASSETS_DIR/gtk-themes/Flat-Remix-GTK-Blue-Dark.tar.gz" ]; then
    tar -xzf "$ASSETS_DIR/gtk-themes/Flat-Remix-GTK-Blue-Dark.tar.gz" -C "$THEMES_DIR" >> "$LOG" 2>&1
    echo -e "${OK} Installed Flat-Remix-GTK-Blue-Dark"
fi

if [ -f "$ASSETS_DIR/gtk-themes/Flat-Remix-GTK-Blue-Light.tar.gz" ]; then
    tar -xzf "$ASSETS_DIR/gtk-themes/Flat-Remix-GTK-Blue-Light.tar.gz" -C "$THEMES_DIR" >> "$LOG" 2>&1
    echo -e "${OK} Installed Flat-Remix-GTK-Blue-Light"
fi

# Extract Icons
echo -e "${NOTE} Installing icon themes..."

if [ -f "$ASSETS_DIR/icons/Bibata-Modern-Ice.zip" ]; then
    unzip -o "$ASSETS_DIR/icons/Bibata-Modern-Ice.zip" -d "$ICONS_DIR" >> "$LOG" 2>&1
    echo -e "${OK} Installed Bibata-Modern-Ice cursor"
fi

if [ -f "$ASSETS_DIR/icons/Flat-Remix-Blue-Dark.zip" ]; then
    unzip -o "$ASSETS_DIR/icons/Flat-Remix-Blue-Dark.zip" -d "$ICONS_DIR" >> "$LOG" 2>&1
    echo -e "${OK} Installed Flat-Remix-Blue-Dark icons"
fi

if [ -f "$ASSETS_DIR/icons/Flat-Remix-Blue-Light.zip" ]; then
    unzip -o "$ASSETS_DIR/icons/Flat-Remix-Blue-Light.zip" -d "$ICONS_DIR" >> "$LOG" 2>&1
    echo -e "${OK} Installed Flat-Remix-Blue-Light icons"
fi

# Apply themes using gsettings
echo -e "${NOTE} Applying theme settings..."

# Set GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue-Dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true

# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark" 2>/dev/null || true

# Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice" 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true

# Create GTK settings files
echo -e "${NOTE} Creating GTK config files..."

# GTK3
ensure_dir "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Flat-Remix-GTK-Blue-Dark
gtk-icon-theme-name=Flat-Remix-Blue-Dark
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=24
gtk-font-name=Cantarell 11
gtk-application-prefer-dark-theme=true
gtk-decoration-layout=:minimize,maximize,close
EOF

# GTK4
ensure_dir "$HOME/.config/gtk-4.0"
cat > "$HOME/.config/gtk-4.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Flat-Remix-GTK-Blue-Dark
gtk-icon-theme-name=Flat-Remix-Blue-Dark
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=24
gtk-font-name=Cantarell 11
gtk-application-prefer-dark-theme=true
EOF

# Hyprland cursor config
if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
    echo -e "${NOTE} Updating Hyprland cursor settings..."
    if ! grep -q "exec-once.*hyprctl setcursor" "$HOME/.config/hypr/hyprland.conf"; then
        echo 'exec-once = hyprctl setcursor Bibata-Modern-Ice 24' >> "$HOME/.config/hypr/hyprland.conf"
    fi
fi

echo -e "${OK} GTK themes and icons installed!"
echo -e "${INFO} Dark theme: ${YELLOW}Flat-Remix-GTK-Blue-Dark${RESET}"
echo -e "${INFO} Light theme: ${YELLOW}Flat-Remix-GTK-Blue-Light${RESET}"
echo -e "${INFO} Icons: ${YELLOW}Flat-Remix-Blue-Dark${RESET}"
echo -e "${INFO} Cursor: ${YELLOW}Bibata-Modern-Ice${RESET}"
