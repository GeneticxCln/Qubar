#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - Temperature Monitor Service
# CPU/GPU temperature alerts with systemd integration
# ═══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global_functions.sh"

LOG="$LOG_DIR/install-$(date +%d-%H%M%S)_temp-monitor.log"

# Required packages
temp_pkgs=(
    lm_sensors
    libnotify
)

print_section "Temperature Monitor Setup"

# Install packages
echo -e "${NOTE} Installing temperature monitor packages..."
for pkg in "${temp_pkgs[@]}"; do
    install_package "$pkg" "$LOG"
done

# Detect sensors
echo -e "${NOTE} Detecting hardware sensors..."
sudo sensors-detect --auto >> "$LOG" 2>&1 || true

# Create monitoring script
MONITOR_SCRIPT="$HOME/.config/qubar/scripts/temp-monitor.sh"
ensure_dir "$(dirname "$MONITOR_SCRIPT")"

cat > "$MONITOR_SCRIPT" << 'EOF'
#!/bin/bash
# Qubar Temperature Monitor
# Monitors CPU/GPU temps and sends alerts

# Configuration
CPU_WARNING=75
CPU_CRITICAL=85
GPU_WARNING=75
GPU_CRITICAL=85
CHECK_INTERVAL=30

# State tracking
NOTIFIED_CPU_WARN=false
NOTIFIED_CPU_CRIT=false
NOTIFIED_GPU_WARN=false
NOTIFIED_GPU_CRIT=false

get_cpu_temp() {
    # Try different sensor patterns
    local temp=$(sensors 2>/dev/null | grep -i 'Package id 0:\|Tdie:\|Tctl:' | awk '{print $4}' | sed 's/+//;s/°C//' | head -1)
    if [ -z "$temp" ]; then
        temp=$(sensors 2>/dev/null | grep -i 'Core 0:' | awk '{print $3}' | sed 's/+//;s/°C//' | head -1)
    fi
    echo "${temp%.*}"
}

get_gpu_temp() {
    # AMD GPU
    local temp=$(sensors 2>/dev/null | grep -i 'edge:' | awk '{print $2}' | sed 's/+//;s/°C//' | head -1)
    # NVIDIA GPU
    if [ -z "$temp" ] && command -v nvidia-smi &>/dev/null; then
        temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | head -1)
    fi
    echo "${temp%.*}"
}

while true; do
    CPU_TEMP=$(get_cpu_temp)
    GPU_TEMP=$(get_gpu_temp)
    
    # Check CPU temperature
    if [ -n "$CPU_TEMP" ] && [ "$CPU_TEMP" -ge 0 ] 2>/dev/null; then
        if [ "$CPU_TEMP" -ge "$CPU_CRITICAL" ]; then
            if [ "$NOTIFIED_CPU_CRIT" = false ]; then
                notify-send -u critical -i dialog-warning "🔥 Critical CPU Temperature" \
                    "CPU at ${CPU_TEMP}°C! System may throttle."
                NOTIFIED_CPU_CRIT=true
                NOTIFIED_CPU_WARN=true
            fi
        elif [ "$CPU_TEMP" -ge "$CPU_WARNING" ]; then
            if [ "$NOTIFIED_CPU_WARN" = false ]; then
                notify-send -u normal -i dialog-information "🌡️ High CPU Temperature" \
                    "CPU at ${CPU_TEMP}°C"
                NOTIFIED_CPU_WARN=true
            fi
        else
            NOTIFIED_CPU_WARN=false
            NOTIFIED_CPU_CRIT=false
        fi
    fi
    
    # Check GPU temperature
    if [ -n "$GPU_TEMP" ] && [ "$GPU_TEMP" -ge 0 ] 2>/dev/null; then
        if [ "$GPU_TEMP" -ge "$GPU_CRITICAL" ]; then
            if [ "$NOTIFIED_GPU_CRIT" = false ]; then
                notify-send -u critical -i dialog-warning "🔥 Critical GPU Temperature" \
                    "GPU at ${GPU_TEMP}°C!"
                NOTIFIED_GPU_CRIT=true
                NOTIFIED_GPU_WARN=true
            fi
        elif [ "$GPU_TEMP" -ge "$GPU_WARNING" ]; then
            if [ "$NOTIFIED_GPU_WARN" = false ]; then
                notify-send -u normal -i dialog-information "🌡️ High GPU Temperature" \
                    "GPU at ${GPU_TEMP}°C"
                NOTIFIED_GPU_WARN=true
            fi
        else
            NOTIFIED_GPU_WARN=false
            NOTIFIED_GPU_CRIT=false
        fi
    fi
    
    sleep "$CHECK_INTERVAL"
done
EOF

chmod +x "$MONITOR_SCRIPT"
echo -e "${OK} Created temperature monitor script"

# Create systemd service
create_user_service "qubar-temp-monitor" "$MONITOR_SCRIPT" "Qubar Temperature Monitor"

echo -e "${OK} Temperature monitor installed and running!"
echo -e "${INFO} View temps: ${YELLOW}sensors${RESET}"
