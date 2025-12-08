# Qubar Installation Guide

## Prerequisites

- **Arch Linux** (or Arch-based distribution)
- Basic command-line knowledge
- Internet connection

## Quick Installation (Recommended)

```bash
git clone https://github.com/GeneticxCln/Qubar.git
cd Qubar
./install.sh
```

The installer will:
1. Verify you're on Arch Linux
2. Optionally backup existing configs
3. Install all required dependencies
4. Deploy Qubar configurations
5. Optionally set up SDDM
6. Set initial wallpaper

## Manual Installation

### 1. Install Dependencies

```bash
# Core
sudo pacman -S hyprland quickshell qt6-declarative qt6-svg

# System tools
sudo pacman -S wpctl brightnessctl networkmanager bluez-utils playerctl

# Wayland ecosystem
sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
sudo pacman -S hyprpaper swaylock-effects hyprshot

# Screenshot & logout tools
sudo pacman -S swappy wlogout

# Optional: Alternative locker & dynamic theming
sudo pacman -S hyprlock wallust

# Optional: Login manager
sudo pacman -S sddm polkit-kde-agent dunst
```

### 2. Deploy Configs

```bash
# QuickShell
cp -r backend topbar panel launcher overview theme modules services shell.qml GlobalStates.qml ~/.config/quickshell/

# Hyprland (modular)
mkdir -p ~/.config/hypr
cp hypr/qubar.conf ~/.config/hypr/hyprland.conf
cp -r hypr/modules ~/.config/hypr/
cp -r hypr/user ~/.config/hypr/

# Other configs
mkdir -p ~/.config/swaylock ~/.config/xdg-desktop-portal ~/.config/swappy ~/.config/wlogout ~/.config/wallust ~/.config/hypr
cp .config/swaylock/config ~/.config/swaylock/
cp .config/xdg-desktop-portal/hyprland-portals.conf ~/.config/xdg-desktop-portal/
cp .config/swappy/config ~/.config/swappy/
cp -r .config/wlogout/* ~/.config/wlogout/
cp -r .config/wallust/* ~/.config/wallust/
cp .config/hypr/hyprlock.conf ~/.config/hypr/

# Scripts
mkdir -p ~/Qubar/scripts ~/Qubar/wallpapers
cp scripts/* ~/Qubar/scripts/
chmod +x ~/Qubar/scripts/*.sh

# Wallpapers (optional)
cp -r wallpapers/* ~/Qubar/wallpapers/
```

### 3. SDDM (Optional)

```bash
sudo ./install-sddm-theme.sh
```

### 4. Initial Setup

```bash
# Set wallpaper
~/Qubar/scripts/set-wallpaper.sh random

# Start Hyprland
Hyprland
```

## Post-Installation

### First Launch

On first Hyprland launch:
1. QuickShell should auto-start with top bar
2. A random wallpaper will be set
3. All keybindings are active

### Verify Installation

- **Top bar visible**: QuickShell is running
- **Super+Q**: Closes active window (test keybind)
- **Print**: Take screenshot with Swappy
- **Super+Shift+E**: Open logout menu

### Customization

See [CUSTOMIZATION.md](CUSTOMIZATION.md) for theming and configuration options.

## Troubleshooting

### QuickShell not starting

```bash
# Check QuickShell logs
journalctl --user -u quickshell

# Manually start
quickshell
```

### No wallpaper

```bash
# Check hyprpaper
killall hyprpaper
hyprpaper &

# Set wallpaper manually
~/Qubar/scripts/set-wallpaper.sh random
```

### Blurry UI or performance issues

Edit `~/.config/hypr/user/user-settings.conf`:
```conf
decoration {
    blur {
        enabled = false  # Disable blur
    }
}
```

### Sound/Brightness controls not working

Ensure required tools are installed:
```bash
sudo pacman -S wpctl brightnessctl
```

## Uninstallation

```bash
# Backup your data first!
~/Qubar/scripts/backup-config.sh

# Remove configs
rm -rf ~/.config/quickshell
rm -rf ~/.config/hypr
rm -rf ~/.config/swaylock
rm -rf ~/Qubar
```

## Next Steps

- [Customization Guide](CUSTOMIZATION.md)
- [Keybind Reference](KEYBINDS.md)
- [FAQ](FAQ.md)
