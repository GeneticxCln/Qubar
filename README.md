# Qubar - Hyprland Desktop Environment

Complete QuickShell-based desktop environment for Hyprland with advanced features.

## ✨ Features

### Core Components
- **Top Tab Bar**: Browser-style window tabs, workspace switcher, system tray
- **Settings Panel**: Audio, Display, Network, Bluetooth, Power, Fan Control
- **App Launcher**: Desktop app search and launch
- **Desktop Overview**: Activities-style workspace grid with search
- **Notification Center**: System notifications with DND mode
- **Media Controls**: MPRIS media player widget

### Hyprland Integration
- **Rainbow Border Gradients**: 7-color RGB gradient on active windows
- **Smooth Animations**: Window open/close, workspace switching, fade effects
- **Auto-start**: QuickShell launches automatically
- **Global Shortcuts**: Super, Super+Tab for launcher and overview
- **SDDM Login Manager**: Simple SDDM theme for elegant login screen

## 🚀 Installation

### Quick Install (Recommended)
```bash
git clone https://github.com/GeneticxCln/Qubar.git
cd Qubar
./install.sh
```

The installer will:
- Check your system (Arch Linux)
- Backup existing configs (optional)
- Install all dependencies
- Deploy Qubar configs
- Set up SDDM (optional)
- Configure initial wallpaper

### Manual Installation

#### Prerequisites

```bash
# Core
yay -S quickshell-git hyprland hyprpaper

# System tools
yay -S brightnessctl gammastep swappy wlogout swaylock hyprlock wallust

# Terminal & File Manager
yay -S kitty thunar thunar-archive-plugin

# Fonts
yay -S ttf-jetbrains-mono-nerd ttf-font-awesome
```

# XDG Desktop Portal (for screen sharing, file pickers)
sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# Wallpaper daemon
sudo pacman -S hyprpaper

# Screenshot tools
sudo pacman -S hyprshot swappy

# Logout menu
sudo pacman -S wlogout

# Screen locker
sudo pacman -S swaylock-effects hyprlock  # Choose one or both

# Dynamic theming
sudo pacman -S wallust

# Optional (for screenshots & notifications)
sudo pacman -S hyprshot dunst
```

### Setup
1. Clone the repository:
```bash
git clone https://github.com/GeneticxCln/Qubar.git
cd Qubar
```

2. Install QuickShell config:
```bash
mkdir -p ~/.config/quickshell
cp -r * ~/.config/quickshell/
```

3. Install Hyprland config:
```bash
cp hyprland.conf ~/.config/hypr/hyprland.conf
```

45. Install XDG portal config:
```bash
mkdir -p ~/.config/xdg-desktop-portal
cp .config/xdg-desktop-portal/hyprland-portals.conf ~/.config/xdg-desktop-portal/
```

6. Install swaylock config:
```bash
mkdir -p ~/.config/swaylock
cp .config/swaylock/config ~/.config/swaylock/
```

7. Install SDDM login manager (optional but recommended):
```bash
sudo ./install-sddm-theme.sh
```

5. Launch Hyprland:
```bash
Hyprland
```

## ⚙️ Configuration

### Hyprland Settings
Edit `~/.config/hypr/hyprland.conf`:
- **Rainbow borders**: Modify `col.active_border` in `general` section
- **Animations**: Adjust bezier curves and animation speeds
- **Keybindings**: Customize under `KEYBINDINGS` section

### QuickShell Theme
Edit `~/.config/quickshell/theme/Theme.qml`:
- Colors, fonts, sizes

### Fan Control (Optional)
Requires passwordless sudo for `/usr/bin/tee`:
```bash
sudo visudo
# Add: yourusername ALL=(ALL) NOPASSWD: /usr/bin/tee
```

## 📁 Project Structure

```
Qubar/
├── backend/                 # Backend controllers
│   ├── HyprlandIPC.qml     # Hyprland socket communication
│   ├── BackendController.qml
│   ├── AppLauncher.qml
│   ├── MediaController.qml
│   ├── NotificationController.qml
│   ├── IconProvider.qml
│   └── settings/           # System settings controllers
├── topbar/                 # Top bar UI
│   └── widgets/
├── panel/                  # Popup panels
│   ├── SettingsPanel.qml
│   ├── NotificationPanel.qml
│   └── widgets/
├── launcher/               # App launcher
├── overview/               # Desktop overview
├── theme/                  # Theme singleton
├── shell.qml              # Entry point
└── hyprland.conf          # Hyprland configuration
```

## 🎨 Features Showcase

### Rainbow Borders
7-color gradient on active windows:
- Red → Orange → Yellow → Green → Blue → Indigo → Violet

### Window Animations
- **Open/Close**: Scale + fade with overshoot
- **Workspace Switch**: Smooth slide
- **Border**: Rotating rainbow gradient

### Media Player
- Album art display
- Play/pause/next/previous controls
- Track progress bar

### Notification Center
- Bell icon with unread badge
- Slide-in panel from top-right
- Clear all & DND toggle

## 🚀 Usage

See [KEYBINDS.md](docs/KEYBINDS.md) for complete keybind reference.

## 📚 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed setup instructions
- **[Customization Guide](docs/CUSTOMIZATION.md)** - Themes, colors, configs
- **[Keybind Reference](docs/KEYBINDS.md)** - All keyboard shortcuts
- **[FAQ & Troubleshooting](docs/FAQ.md)** - Common issues and solutions
- **[SDDM Wallpaper Sync](docs/SDDM_WALLPAPER.md)** - Login screen wallpapers

## 🛠️ Troubleshooting

**QuickShell not starting:**
```bash
quickshell -l  # Check logs
```

**Fan control not working:**
- Verify passwordless sudo for `/usr/bin/tee`
- Check hwmon device detection

**Notifications not appearing:**
- Ensure `dunst` or `swaync` is running

## 📝 License

MIT License - See LICENSE file

## 🙏 Credits

- Built with [QuickShell](https://github.com/outfoxxed/quickshell)
- Designed for [Hyprland](https://hyprland.org)
