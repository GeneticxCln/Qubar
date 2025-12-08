# Qubar Customization Guide

## Theme Customization

### Switching Themes

Qubar supports 3 themes:
- **Dark** (default) - Dracula/Slate inspired
- **Light** - Light mode variant
- **Wallust** - Dynamic colors from wallpaper

**Change theme in QML console or add UI:**
```qml
Theme.setTheme("dark")    // Dark theme
Theme.setTheme("light")   // Light theme
Theme.setTheme("wallust") // Dynamic from wallpaper
```

**Cycle themes:**
```qml
Theme.toggleTheme()  // Dark → Light → Wallust → Dark
```

### Dynamic Theming (Wallust)

Automatically extract colors from wallpaper:

1. **Install Wallust:**
```bash
sudo pacman -S wallust
```

2. **Change wallpaper:**
```bash
~/Qubar/scripts/set-wallpaper.sh random
```

3. **Colors auto-extracted** to `~/.config/quickshell/wallust-colors.qml`

4. **Switch to dynamic theme:**
```qml
Theme.setTheme("wallust")
```

### Custom Color Schemes

Create your own theme in `~/.config/quickshell/theme/themes/`:

```qml
// MyTheme.qml
import QtQuick

QtObject {
    readonly property string name: "My Theme"
    readonly property color background: "#1e1e2e"
    readonly property color accent: "#89b4fa"
    // ... other colors
}
```

Add to `ThemeManager.qml`:
```qml
property var myTheme: MyTheme {}
```

## Hyprland Customization

### User Overrides

**Never edit base configs!** Use user overrides in `~/.config/hypr/user/`:

#### Change Border Size
`~/.config/hypr/user/user-settings.conf`:
```conf
general {
    border_size = 3
    gaps_in = 10
    gaps_out = 20
}
```

#### Custom Keybinds
`~/.config/hypr/user/user-keybinds.conf`:
```conf
$mainMod = SUPER

bind = $mainMod, B, exec, firefox
bind = $mainMod, E, exec, thunar
bind = $mainMod, C, exec, code
```

#### Window Rules
`~/.config/hypr/user/user-rules.conf`:
```conf
windowrulev2 = float,class:^(discord)$
windowrulev2 = opacity 0.85 0.85,class:^(code)$
```

### Screen Locker Preference

Choose between swaylock and hyprlock:

`~/.config/hypr/user/locker-preference.conf`:
```conf
# Uncomment your choice:
$lock_cmd = swaylock   # Default
# $lock_cmd = hyprlock # Alternative
```

## Wallpaper Management

### Change Wallpaper

```bash
# Random wallpaper
~/Qubar/scripts/set-wallpaper.sh random

# Specific wallpaper
~/Qubar/scripts/set-wallpaper.sh /path/to/image.jpg
```

### Add Your Own Wallpapers

```bash
cp /path/to/your/wallpapers/* ~/Qubar/wallpapers/
```

### Disable Auto-Wallpaper on Startup

Edit `~/.config/hypr/modules/startup.conf`:
```conf
# Comment out:
# exec-once = ~/Qubar/scripts/set-wallpaper.sh random
```

## UI Customization

### Top Bar Size

`~/.config/quickshell/theme/Theme.qml`:
```qml
readonly property int barHeight: 50  // Default: 40
```

### Panel Opacity

`~/.config/quickshell/topbar/TopBar.qml`:
```qml
opacity: 1.0  // Range: 0.0 to 1.0
```

### Workspace Count

`~/.config/quickshell/backend/HyprlandIPC.qml`:
```qml
property int workspaceCount: 10  // Default: 9
```

## Animations & Effects

### Disable Animations

`~/.config/hypr/user/user-settings.conf`:
```conf
animations {
    enabled = false
}
```

### Adjust Animation Speed

`~/.config/hypr/modules/decorations.conf`:
```conf
animation = windows, 1, 3, overshot, slide  # Faster (was 5)
```

### Disable Blur

`~/.config/hypr/user/user-settings.conf`:
```conf
decoration {
    blur {
        enabled = false
    }
}
```

## Power Management

### Custom Power Actions

Edit `~/.config/quickshell/backend/settings/PowerController.qml` to change:
- Lock screen command
- Suspend behavior
- Shutdown prompts

### Logout Menu Options

Edit `~/.config/wlogout/layout` to add/remove options.

## Screenshot Workflow

### Disable Swappy Editing

Edit `~/.config/hypr/modules/keybinds.conf`:
```conf
# Direct save (no editing):
bind = , Print, exec, hyprshot -m region -o ~/Pictures/Screenshots
```

### Change Screenshot Directory

`~/.config/swappy/config`:
```ini
save_dir=$HOME/Pictures/MyScreenshots
```

## Fan Control (If Supported)

### Change Fan Presets

Edit `~/.config/quickshell/backend/settings/FanController.qml`:
```qml
readonly property var presets: {
    "Silent": 30,      // 30% speed
    "Quiet": 50,
    "Performance": 80,
    "Max": 100
}
```

## Backup & Restore

### Create Backup

```bash
~/Qubar/scripts/backup-config.sh
```

Backups stored in `~/qubar-backups/`

### Restore Backup

```bash
cd ~/qubar-backups
tar -xzf qubar-backup-YYYYMMDD-HHMMSS.tar.gz -C ~
```

## Advanced Customization

### Add Custom Widgets

Create QML files in `~/.config/quickshell/modules/` and import in relevant panels.

### Modify Notification Behavior

Edit `~/.config/quickshell/backend/NotificationController.qml`.

### Change Media Player Source

Edit `~/.config/quickshell/backend/MediaController.qml` to change playerctl filters.

## Troubleshooting Customization

### Changes Not Applying

```bash
# Restart QuickShell
killall quickshell
quickshell &

# Reload Hyprland config
hyprctl reload
```

### Syntax Errors

Check logs:
```bash
journalctl --user -u quickshell -f
```

### Reset to Defaults

```bash
# Restore from backup or re-run installer
./install.sh
```

## Resources

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [QuickShell Docs](https://quickshell.outfoxxed.me/)
- [Qubar GitHub](https://github.com/GeneticxCln/Qubar)
