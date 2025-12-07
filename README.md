# Qubar - QuickShell Top Bar

A powerful, feature-rich QuickShell configuration for Hyprland featuring a browser-style tab bar, settings panel, app launcher, and desktop overview.

![Platform](https://img.shields.io/badge/Platform-Linux-blue)
![Compositor](https://img.shields.io/badge/Compositor-Hyprland-green)
![Framework](https://img.shields.io/badge/Framework-QuickShell-purple)

## ✨ Features

- 🌐 **Browser-Style Tab Bar** - Window tabs with close button and visual feedback
- 🖥️ **Desktop Overview** - 5x2 workspace grid with window previews
- 🚀 **App Launcher** - Fast application search and launch
- ⚙️ **Settings Panel** - Audio, display, network, bluetooth, power, and fan control
- 🌀 **Fan Control** - NCT67xx-based hardware fan management
- ⌨️ **Global Shortcuts** - Super for launcher, Super+Tab for overview
- ✨ **Material Design** - Ripple effects and smooth animations

## 📦 Installation

```bash
git clone https://github.com/YOUR_USERNAME/Qubar.git ~/.config/quickshell
```

## 🎮 Usage

```bash
quickshell
```

### Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| Super | Toggle App Launcher |
| Super+Tab | Toggle Desktop Overview |
| Click System Tray | Open Settings Panel |
| Click Start Button | Open App Launcher |

## 📁 Structure

```
~/.config/quickshell/
├── shell.qml              # Entry point
├── theme/                 # Styling
├── backend/               # Controllers & IPC
│   ├── settings/         # System controllers
│   └── models/           # Data models
├── topbar/               # Tab bar UI
├── panel/                # Settings popup
├── launcher/             # App launcher
└── overview/             # Workspace grid
```

## 🔧 Requirements

- Hyprland
- QuickShell
- wpctl, brightnessctl, nmcli (for settings)
- nct6775 module (for fan control)

## 📄 License

MIT
# Qubar
# Qubar
# Qubar
# Qubar
