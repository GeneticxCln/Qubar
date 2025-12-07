# SDDM Wallpaper Sync

The desktop wallpaper automatically syncs with SDDM login screen.

## How It Works

Whenever you change the wallpaper using `set-wallpaper.sh`, it:
1. Sets the desktop wallpaper (hyprpaper)
2. Sets the lock screen wallpaper (swaylock)
3. **Sets the SDDM login screen wallpaper** (requires sudo)

## Files

- **Desktop**: `~/Qubar/wallpapers/current.jpg` → hyprpaper
- **Lock Screen**: `~/.config/swaylock/current_wallpaper.jpg` → swaylock
- **Login Screen**: `/usr/share/sddm/themes/simple-sddm/background.jpg` → SDDM

## Usage

```bash
# Change all wallpapers (desktop + lock + login)
~/Qubar/scripts/set-wallpaper.sh random

# Set specific wallpaper
~/Qubar/scripts/set-wallpaper.sh /path/to/wallpaper.jpg
```

**Note**: SDDM wallpaper update requires sudo. The script will warn if it fails.

## Sudo Configuration (Optional)

To avoid sudo password prompt for wallpaper changes:

```bash
sudo visudo
# Add: username ALL=(ALL) NOPASSWD: /usr/bin/cp
```
