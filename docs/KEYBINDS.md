# Qubar Keybind Reference

## Modifier Keys

- `$mainMod` = **Super** (Windows key)

## Window Management

| Keybind | Action |
|---------|--------|
| `Super + Return` | Open terminal (kitty) |
| `Super + Q` | Close active window |
| `Super + V` | Toggle floating |
| `Super + F` | Fullscreen |
| `Super + P` | Pseudo-tile (dwindle) |
| `Super + J` | Toggle split (dwindle) |

## Window Navigation

| Keybind | Action |
|---------|--------|
| `Super + ←/→/↑/↓` | Move focus |
| `Super + Mouse Left` | Move window |
| `Super + Mouse Right` | Resize window |

## Workspaces

| Keybind | Action |
|---------|--------|
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + 0` | Switch to workspace 10 |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + Mouse Scroll` | Scroll through workspaces |

## Special Workspaces

| Keybind | Action |
|---------|--------|
| `Super + S` | Toggle scratchpad |
| `Super + Shift + S` | Move to scratchpad |

## System

| Keybind | Action |
|---------|--------|
| `Super + L` | Lock screen (swaylock or hyprlock) |
| `Super + Shift + E` | Logout menu (wlogout) |

## Screenshots

| Keybind | Action |
|---------|--------|
| `Print` | Region screenshot → Swappy editor |
| `Shift + Print` | Window screenshot → Swappy editor |
| `Ctrl + Print` | Full screen screenshot (direct save) |

All screenshots save to `~/Pictures/Screenshots/`

## wlogout Menu (Super+Shift+E)

When logout menu is open:
- `L` - Lock screen
- `E` - Logout
- `U` - Suspend
- `H` - Hibernate
- `R` - Reboot
- `S` - Shutdown
- `Esc` - Cancel

## QuickShell Panels

QuickShell panels are accessed via mouse clicks:
- **Top Bar** - Always visible
  - Click workspace numbers to switch
  - Click window tabs to focus
  - Click system tray for settings
- **Settings Panel** - Click gear icon in system tray
- **App Launcher** - (Add keybind if needed)
- **Desktop Overview** - (Add keybind if needed)

## Custom Keybinds

Add your own in `~/.config/hypr/user/user-keybinds.conf`:

```conf
$mainMod = SUPER

# Example: App shortcuts
bind = $mainMod, B, exec, firefox
bind = $mainMod, E, exec, thunar
bind = $mainMod, C, exec, code

# Example: Media keys
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous
```

## Default Hyprland Keybinds

Additional Hyprland keybinds (not customized by Qubar):
- See [Hyprland Wiki - Binds](https://wiki.hyprland.org/Configuring/Binds/)

## Quick Reference Card

```
┌────────────────────────────────────────┐
│         QUBAR KEYBIND CHEAT SHEET      │
├────────────────────────────────────────┤
│ Super+Return  → Terminal               │
│ Super+Q       → Close window           │
│ Super+L       → Lock                   │
│ Super+Shift+E → Logout menu            │
│ Print         → Screenshot (region)    │
│ Super+1-9     → Workspaces             │
└────────────────────────────────────────┘
```
