#!/bin/bash
# ╔═══════════════════════════════════════════════════════════╗
# ║              Qubar Wallpaper Selector Script              ║
# ║          Selects random wallpaper and sets it up          ║
# ╚═══════════════════════════════════════════════════════════╝

WALLPAPER_DIR="$HOME/Qubar/wallpapers"
CURRENT_LINK="$WALLPAPER_DIR/current.jpg"
SWAYLOCK_CURRENT="$HOME/.config/swaylock/current_wallpaper.jpg"
SDDM_THEME_DIR="/usr/share/sddm/themes/simple-sddm"
SDDM_WALLPAPER="$SDDM_THEME_DIR/background.jpg"

# Function to select random wallpaper
select_random_wallpaper() {
    # Find all image files (excluding Dynamic-Wallpapers subdirs for now)
    WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
    
    # Fallback to any wallpaper if none found at root
    if [ -z "$WALLPAPER" ]; then
        WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
    fi
    
    echo "$WALLPAPER"
}

# Function to set wallpaper
set_wallpaper() {
    local WALLPAPER="$1"
    
    # Create symlink for hyprpaper
    ln -sf "$WALLPAPER" "$CURRENT_LINK"
    
    # Copy for swaylock
    mkdir -p "$(dirname "$SWAYLOCK_CURRENT")"
    cp "$WALLPAPER" "$SWAYLOCK_CURRENT"
    
    # Copy for SDDM theme (requires sudo)
    if [ -d "$SDDM_THEME_DIR" ]; then
        sudo cp "$WALLPAPER" "$SDDM_WALLPAPER" 2>/dev/null || {
            echo "Warning: Could not update SDDM wallpaper (needs sudo)"
        }
    fi
    
    # Reload hyprpaper if running
    if pgrep -x hyprpaper > /dev/null; then
        killall hyprpaper
        sleep 0.5
    fi
    hyprpaper &
    
    echo "Wallpaper set to: $(basename "$WALLPAPER")"
}

# Main
if [ "$1" = "random" ] || [ -z "$1" ]; then
    SELECTED=$(select_random_wallpaper)
    set_wallpaper "$SELECTED"
elif [ -f "$1" ]; then
    # Set specific wallpaper
    set_wallpaper "$1"
else
    echo "Usage: $0 [random|/path/to/wallpaper.jpg]"
    exit 1
fi

