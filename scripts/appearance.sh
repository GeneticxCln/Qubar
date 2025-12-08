#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Qubar Appearance Controller Script
# Modifies Hyprland decoration settings on the fly
# ═══════════════════════════════════════════════════════════

DECORATIONS_FILE="$HOME/Qubar/hypr/modules/decorations.conf"
USER_SETTINGS_FILE="$HOME/Qubar/hypr/user/user-settings.conf"

# Ensure user settings file exists
mkdir -p "$(dirname "$USER_SETTINGS_FILE")"
touch "$USER_SETTINGS_FILE"

case "$1" in
    # ═══════════════════════════════════════════════════════════
    # BLUR CONTROLS
    # ═══════════════════════════════════════════════════════════
    blur-enable)
        hyprctl keyword decoration:blur:enabled true
        echo "Blur enabled"
        ;;
    blur-disable)
        hyprctl keyword decoration:blur:enabled false
        echo "Blur disabled"
        ;;
    blur-size)
        # $2 = size (1-20)
        hyprctl keyword decoration:blur:size "$2"
        echo "Blur size set to $2"
        ;;
    blur-passes)
        # $2 = passes (1-6)
        hyprctl keyword decoration:blur:passes "$2"
        echo "Blur passes set to $2"
        ;;
    
    # ═══════════════════════════════════════════════════════════
    # OPACITY CONTROLS
    # ═══════════════════════════════════════════════════════════
    active-opacity)
        # $2 = opacity (0.5-1.0)
        hyprctl keyword decoration:active_opacity "$2"
        echo "Active opacity set to $2"
        ;;
    inactive-opacity)
        # $2 = opacity (0.5-1.0)
        hyprctl keyword decoration:inactive_opacity "$2"
        echo "Inactive opacity set to $2"
        ;;
    
    # ═══════════════════════════════════════════════════════════
    # ANIMATION CONTROLS
    # ═══════════════════════════════════════════════════════════
    animations-enable)
        hyprctl keyword animations:enabled true
        echo "Animations enabled"
        ;;
    animations-disable)
        hyprctl keyword animations:enabled false
        echo "Animations disabled"
        ;;
    animation-speed)
        # $2 = speed multiplier (0.5=fast, 1.0=normal, 2.0=slow)
        # This affects all animation durations
        # We modify bezier curves to achieve speed change
        case "$2" in
            fast)
                hyprctl keyword animation windows,1,3,overshot,slide
                hyprctl keyword animation fade,1,3,smoothIn
                hyprctl keyword animation workspaces,1,4,overshot,slide
                ;;
            normal)
                hyprctl keyword animation windows,1,5,overshot,slide
                hyprctl keyword animation fade,1,5,smoothIn
                hyprctl keyword animation workspaces,1,6,overshot,slide
                ;;
            slow)
                hyprctl keyword animation windows,1,8,overshot,slide
                hyprctl keyword animation fade,1,8,smoothIn
                hyprctl keyword animation workspaces,1,10,overshot,slide
                ;;
        esac
        echo "Animation speed set to $2"
        ;;
    
    # ═══════════════════════════════════════════════════════════
    # BORDER CONTROLS
    # ═══════════════════════════════════════════════════════════
    border-rainbow)
        hyprctl keyword general:col.active_border "rgb(ff0000) rgb(ff7f00) rgb(ffff00) rgb(00ff00) rgb(0000ff) rgb(4b0082) rgb(9400d3) 45deg"
        hyprctl keyword animation borderangle,1,100,default,loop
        echo "Rainbow border enabled"
        ;;
    border-solid)
        # $2 = color (hex without #)
        hyprctl keyword general:col.active_border "rgb(${2:-81a1c1})"
        hyprctl keyword animation borderangle,0,1,default
        echo "Solid border set to $2"
        ;;
    border-accent)
        # Use theme accent color
        hyprctl keyword general:col.active_border "rgb(81a1c1)"
        hyprctl keyword animation borderangle,0,1,default
        echo "Accent border enabled"
        ;;
    
    # ═══════════════════════════════════════════════════════════
    # SHADOW CONTROLS
    # ═══════════════════════════════════════════════════════════
    shadow-enable)
        hyprctl keyword decoration:drop_shadow true
        echo "Shadows enabled"
        ;;
    shadow-disable)
        hyprctl keyword decoration:drop_shadow false
        echo "Shadows disabled"
        ;;
    shadow-range)
        # $2 = range (5-50)
        hyprctl keyword decoration:shadow_range "$2"
        echo "Shadow range set to $2"
        ;;
    
    # ═══════════════════════════════════════════════════════════
    # CORNER ROUNDING
    # ═══════════════════════════════════════════════════════════
    rounding)
        # $2 = radius (0-20)
        hyprctl keyword decoration:rounding "$2"
        echo "Corner rounding set to $2"
        ;;
    
    # ═══════════════════════════════════════════════════════════
    # GAPS
    # ═══════════════════════════════════════════════════════════
    gaps-in)
        hyprctl keyword general:gaps_in "$2"
        echo "Inner gaps set to $2"
        ;;
    gaps-out)
        hyprctl keyword general:gaps_out "$2"
        echo "Outer gaps set to $2"
        ;;
    
    # ═══════════════════════════════════════════════════════════
    # GET CURRENT VALUES
    # ═══════════════════════════════════════════════════════════
    get-all)
        echo "{"
        echo "  \"blur\": $(hyprctl getoption decoration:blur:enabled -j | jq '.int == 1'),"
        echo "  \"blurSize\": $(hyprctl getoption decoration:blur:size -j | jq '.int'),"
        echo "  \"blurPasses\": $(hyprctl getoption decoration:blur:passes -j | jq '.int'),"
        echo "  \"animations\": $(hyprctl getoption animations:enabled -j | jq '.int == 1'),"
        echo "  \"activeOpacity\": $(hyprctl getoption decoration:active_opacity -j | jq '.float'),"
        echo "  \"inactiveOpacity\": $(hyprctl getoption decoration:inactive_opacity -j | jq '.float'),"
        echo "  \"shadows\": $(hyprctl getoption decoration:drop_shadow -j | jq '.int == 1'),"
        echo "  \"rounding\": $(hyprctl getoption decoration:rounding -j | jq '.int'),"
        echo "  \"gapsIn\": $(hyprctl getoption general:gaps_in -j | jq '.int'),"
        echo "  \"gapsOut\": $(hyprctl getoption general:gaps_out -j | jq '.int')"
        echo "}"
        ;;
    
    *)
        echo "Usage: $0 <command> [value]"
        echo "Commands:"
        echo "  blur-enable, blur-disable, blur-size <1-20>, blur-passes <1-6>"
        echo "  active-opacity <0.5-1.0>, inactive-opacity <0.5-1.0>"
        echo "  animations-enable, animations-disable, animation-speed <fast|normal|slow>"
        echo "  border-rainbow, border-solid <hex>, border-accent"
        echo "  shadow-enable, shadow-disable, shadow-range <5-50>"
        echo "  rounding <0-20>, gaps-in <0-20>, gaps-out <0-30>"
        echo "  get-all"
        exit 1
        ;;
esac
