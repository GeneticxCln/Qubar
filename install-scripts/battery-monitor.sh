#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - Battery Monitor Service
# Low battery notifications with systemd integration
# ═══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global_functions.sh"

LOG="$LOG_DIR/install-$(date +%d-%H%M%S)_battery-monitor.log"

# Required packages
battery_pkgs=(
    acpi
    libnotify
)

print_section "Battery Monitor Setup"

# Install packages
echo -e "${NOTE} Installing battery monitor packages..."
for pkg in "${battery_pkgs[@]}"; do
    install_package "$pkg" "$LOG"
done

# Create monitoring script
MONITOR_SCRIPT="$HOME/.config/qubar/scripts/battery-monitor.sh"
ensure_dir "$(dirname "$MONITOR_SCRIPT")"

cat > "$MONITOR_SCRIPT" << 'EOF'
#!/bin/bash
# Qubar Battery Monitor
# Monitors battery level and sends notifications

# Configuration
LOW_THRESHOLD=20
CRITICAL_THRESHOLD=10
CHECK_INTERVAL=60

# State tracking
NOTIFIED_LOW=false
NOTIFIED_CRITICAL=false

while true; do
    # Get battery info
    BATTERY_LEVEL=$(acpi -b 2>/dev/null | grep -P -o '[0-9]+(?=%)' | head -1)
    BATTERY_STATUS=$(acpi -b 2>/dev/null | grep -o 'Discharging\|Charging\|Full' | head -1)
    
    # Skip if no battery
    if [ -z "$BATTERY_LEVEL" ]; then
        sleep "$CHECK_INTERVAL"
        continue
    fi
    
    # Only notify when discharging
    if [ "$BATTERY_STATUS" = "Discharging" ]; then
        if [ "$BATTERY_LEVEL" -le "$CRITICAL_THRESHOLD" ] && [ "$NOTIFIED_CRITICAL" = false ]; then
            notify-send -u critical -i battery-caution "⚠️ Critical Battery" \
                "Battery at ${BATTERY_LEVEL}%! Plug in immediately!"
            NOTIFIED_CRITICAL=true
            NOTIFIED_LOW=true
            
        elif [ "$BATTERY_LEVEL" -le "$LOW_THRESHOLD" ] && [ "$NOTIFIED_LOW" = false ]; then
            notify-send -u normal -i battery-low "🔋 Low Battery" \
                "Battery at ${BATTERY_LEVEL}%. Consider plugging in."
            NOTIFIED_LOW=true
        fi
    else
        # Reset when charging
        NOTIFIED_LOW=false
        NOTIFIED_CRITICAL=false
    fi
    
    sleep "$CHECK_INTERVAL"
done
EOF

chmod +x "$MONITOR_SCRIPT"
echo -e "${OK} Created battery monitor script"

# Create systemd service
create_user_service "qubar-battery-monitor" "$MONITOR_SCRIPT" "Qubar Battery Monitor"

echo -e "${OK} Battery monitor installed and running!"
echo -e "${INFO} To check status: ${YELLOW}systemctl --user status qubar-battery-monitor${RESET}"
