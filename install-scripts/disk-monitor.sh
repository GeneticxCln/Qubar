#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - Disk Space Monitor Service
# Low disk space warnings with systemd integration
# ═══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global_functions.sh"

LOG="$LOG_DIR/install-$(date +%d-%H%M%S)_disk-monitor.log"

# Required packages
disk_pkgs=(
    libnotify
)

print_section "Disk Space Monitor Setup"

# Install packages
echo -e "${NOTE} Installing disk monitor packages..."
for pkg in "${disk_pkgs[@]}"; do
    install_package "$pkg" "$LOG"
done

# Create monitoring script
MONITOR_SCRIPT="$HOME/.config/qubar/scripts/disk-monitor.sh"
ensure_dir "$(dirname "$MONITOR_SCRIPT")"

cat > "$MONITOR_SCRIPT" << 'EOF'
#!/bin/bash
# Qubar Disk Space Monitor
# Monitors disk usage and sends warnings

# Configuration
WARNING_THRESHOLD=80
CRITICAL_THRESHOLD=90
CHECK_INTERVAL=300  # 5 minutes

# State tracking (associative array)
declare -A NOTIFIED_WARNING
declare -A NOTIFIED_CRITICAL

while true; do
    # Check each mounted filesystem
    while IFS= read -r line; do
        DEVICE=$(echo "$line" | awk '{print $1}')
        MOUNT=$(echo "$line" | awk '{print $6}')
        USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        
        # Skip non-numeric
        if ! [[ "$USAGE" =~ ^[0-9]+$ ]]; then
            continue
        fi
        
        # Skip small filesystems like /boot
        SIZE=$(echo "$line" | awk '{print $2}')
        if [[ "$SIZE" == *M* ]] || [[ "$SIZE" == *K* ]]; then
            continue
        fi
        
        if [ "$USAGE" -ge "$CRITICAL_THRESHOLD" ]; then
            if [ "${NOTIFIED_CRITICAL[$MOUNT]}" != "true" ]; then
                notify-send -u critical -i drive-harddisk "💾 Critical Disk Space" \
                    "$MOUNT is ${USAGE}% full!"
                NOTIFIED_CRITICAL[$MOUNT]="true"
                NOTIFIED_WARNING[$MOUNT]="true"
            fi
        elif [ "$USAGE" -ge "$WARNING_THRESHOLD" ]; then
            if [ "${NOTIFIED_WARNING[$MOUNT]}" != "true" ]; then
                notify-send -u normal -i drive-harddisk "💾 Low Disk Space" \
                    "$MOUNT is ${USAGE}% full"
                NOTIFIED_WARNING[$MOUNT]="true"
            fi
        else
            # Reset when usage drops
            if [ "$USAGE" -lt $((WARNING_THRESHOLD - 5)) ]; then
                NOTIFIED_WARNING[$MOUNT]="false"
                NOTIFIED_CRITICAL[$MOUNT]="false"
            fi
        fi
    done < <(df -h | grep '^/dev/')
    
    sleep "$CHECK_INTERVAL"
done
EOF

chmod +x "$MONITOR_SCRIPT"
echo -e "${OK} Created disk monitor script"

# Create systemd service
create_user_service "qubar-disk-monitor" "$MONITOR_SCRIPT" "Qubar Disk Space Monitor"

echo -e "${OK} Disk monitor installed and running!"
echo -e "${INFO} View disk usage: ${YELLOW}df -h${RESET}"
