# Qubar FAQ & Troubleshooting

## Frequently Asked Questions

### Q: What is Qubar?
**A:** Qubar is a QuickShell-based desktop environment for Hyprland. It provides a complete, integrated UI with top bar, settings panel, app launcher, and more.

### Q: Do I need to know QML?
**A:** No, for basic usage. Yes, if you want to customize UI components. The user override system allows config changes without touching QML.

### Q: Can I use Qubar with Waybar/AGS?
**A:** No, Qubar is QuickShell-only by design for consistency. If you want modularity, see [JaKooLit's dotfiles](https://github.com/JaKooLit/Hyprland-Dots).

### Q: How much RAM does Qubar use?
**A:** Approximately 50-100MB for QuickShell, plus Hyprland's base usage (~100MB). Very lightweight.

### Q: Can I run Qubar on other distros?
**A:** Currently Arch Linux only. The installer checks for this. Manual installation on other distros is possible but unsupported.

### Q: Where are my wallpapers?
**A:** `~/Qubar/wallpapers/` - 1.1GB of wallpapers included.

### Q: How do I update Qubar?
**A:** 
```bash
cd ~/Qubar
git pull
./install.sh  # Re-run installer
```

## Common Issues

### QuickShell not starting

**Symptoms:** No top bar visible

**Solutions:**
1. Check if QuickShell is installed:
```bash
which quickshell
```

2. Start manually:
```bash
quickshell
```

3. Check logs:
```bash
journalctl --user -u quickshell -f
```

4. Reinstall:
```bash
cd ~/Qubar
./install.sh
```

### Hyprland crashes on startup

**Symptoms:** Returns to TTY or login screen

**Solutions:**
1. Check Hyprland config syntax:
```bash
hyprctl reload  # If Hyprland is running
```

2. Test with minimal config:
```bash
mv ~/.config/hypr ~/.config/hypr.backup
Hyprland  # Test with defaults
```

3. Check logs:
```bash
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log
```

### No wallpaper showing

**Solutions:**
1. Check if hyprpaper is running:
```bash
pgrep hyprpaper
```

2. Kill and restart:
```bash
killall hyprpaper
hyprpaper &
```

3. Set wallpaper manually:
```bash
~/Qubar/scripts/set-wallpaper.sh random
```

4. Check if wallpapers exist:
```bash
ls ~/Qubar/wallpapers/
```

### Blur effects causing lag

**Symptoms:** Choppy animations, high GPU usage

**Solutions:**
1. Disable blur in user settings:
`~/.config/hypr/user/user-settings.conf`:
```conf
decoration {
    blur {
        enabled = false
    }
}
```

2. Reduce blur passes:
```conf
decoration {
    blur {
        passes = 1  # Default: 3
    }
}
```

3. Reload config:
```bash
hyprctl reload
```

### Audio/Brightness controls not working

**Solutions:**
1. Install required tools:
```bash
sudo pacman -S wpctl brightnessctl
```

2. Check permissions:
```bash
ls -l /sys/class/backlight/*/brightness
```

3. Restart QuickShell:
```bash
killall quickshell && quickshell &
```

### Screenshots not saving

**Solutions:**
1. Create screenshots directory:
```bash
mkdir -p ~/Pictures/Screenshots
```

2. Check if hyprshot is installed:
```bash
which hyprshot
```

3. Test manually:
```bash
hyprshot -m region
```

### SDDM not showing custom theme

**Solutions:**
1. Check SDDM config:
```bash
cat /etc/sddm.conf.d/sddm.conf
```

2. Verify theme exists:
```bash
ls /usr/share/sddm/themes/simple-sddm/
```

3. Re-run installer:
```bash
sudo ./install-sddm-theme.sh
```

### Swaylock/Hyprlock not locking

**Solutions:**
1. Check which locker is configured:
```bash
cat ~/.config/hypr/user/locker-preference.conf
```

2. Test locker manually:
```bash
swaylock
# or
hyprlock
```

3. Check if wallpaper exists:
```bash
ls ~/.config/swaylock/current_wallpaper.jpg
```

### Theme not changing

**Solutions:**
1. Check theme state:
```bash
cat ~/.config/quickshell/theme_state.json
```

2. For Wallust theme, check if colors file exists:
```bash
cat ~/.config/quickshell/wallust-colors.qml
```

3. Ensure Wallust is installed:
```bash
which wallust
```

4. Re-run wallpaper script:
```bash
~/Qubar/scripts/set-wallpaper.sh random
```

### High CPU usage

**Possible causes:**
- Wallpaper animations (if using swww instead of hyprpaper)
- Too many blur effects
- Buggy application

**Solutions:**
1. Check CPU usage:
```bash
htop
```

2. Disable animations temporarily:
`~/.config/hypr/user/user-settings.conf`:
```conf
animations {
    enabled = false
}
```

3. Reload Hyprland:
```bash
hyprctl reload
```

## Getting Help

1. **Check logs first:**
```bash
journalctl --user -u quickshell -f
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log
```

2. **GitHub Issues:**
[https://github.com/GeneticxCln/Qubar/issues](https://github.com/GeneticxCln/Qubar/issues)

3. **Hyprland Discord:**
[https://discord.gg/hyprland](https://discord.gg/hyprland)

## Reset to Defaults

If all else fails:

```bash
# Backup first!
~/Qubar/scripts/backup-config.sh

# Remove all configs
rm -rf ~/.config/quickshell
rm -rf ~/.config/hypr
rm -rf ~/.config/swaylock

# Re-install
cd ~/Qubar
./install.sh
```

## Known Issues

### Fan Control
- Only works on systems with `/sys/class/hwmon/hwmon*/pwm*`
- Requires passwordless sudo for `/usr/bin/tee`

### Notification Backend
- Requires `swaync` or `dunst` for notification history
- Limited to command-line tools (no D-Bus integration yet)

### Multi-monitor
- Hyprland config defaults to `monitor=,preferred,auto,1`
- Custom monitor setups need manual configuration in `~/.config/hypr/user/user-settings.conf`
