#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - NVIDIA Driver Setup
# Automated NVIDIA driver installation with proper configuration
# ═══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global_functions.sh"

LOG="$LOG_DIR/install-$(date +%d-%H%M%S)_nvidia.log"

# NVIDIA packages
nvidia_pkgs=(
    nvidia-dkms
    nvidia-settings
    nvidia-utils
    libva
    libva-nvidia-driver
)

print_section "NVIDIA Driver Setup"

# Check for NVIDIA GPU
if ! lspci | grep -i nvidia &>/dev/null; then
    echo -e "${WARN} No NVIDIA GPU detected. Skipping..."
    exit 0
fi

echo -e "${INFO} NVIDIA GPU detected!"

# Remove conflicting packages
echo -e "${NOTE} Checking for conflicting packages..."
for pkg in hyprland-nvidia hyprland-nvidia-git; do
    if pacman -Qs "$pkg" &>/dev/null; then
        echo -e "${NOTE} Removing $pkg..."
        sudo pacman -R --noconfirm "$pkg" >> "$LOG" 2>&1 || true
    fi
done

# Install kernel headers and NVIDIA packages
echo -e "${NOTE} Installing NVIDIA packages..."

# Get current kernel
for krnl in $(cat /usr/lib/modules/*/pkgbase 2>/dev/null | head -1); do
    install_package "${krnl}-headers" "$LOG"
done

for pkg in "${nvidia_pkgs[@]}"; do
    install_package "$pkg" "$LOG"
done

# Configure mkinitcpio
echo -e "${NOTE} Configuring mkinitcpio..."
MKINIT="/etc/mkinitcpio.conf"

if grep -qE '^MODULES=.*nvidia.*nvidia_modeset.*nvidia_uvm.*nvidia_drm' "$MKINIT"; then
    echo -e "${INFO} NVIDIA modules already in mkinitcpio.conf"
else
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' "$MKINIT" >> "$LOG" 2>&1
    echo -e "${OK} Added NVIDIA modules to mkinitcpio.conf"
fi

# Rebuild initramfs
echo -e "${NOTE} Rebuilding initramfs..."
sudo mkinitcpio -P >> "$LOG" 2>&1 || {
    echo -e "${ERROR} Failed to rebuild initramfs. Check $LOG"
}

# Create nvidia.conf for modprobe
NVIDIA_CONF="/etc/modprobe.d/nvidia.conf"
if [ ! -f "$NVIDIA_CONF" ]; then
    echo -e "${NOTE} Creating nvidia modprobe config..."
    echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee "$NVIDIA_CONF" >> "$LOG" 2>&1
    echo -e "${OK} Created $NVIDIA_CONF"
else
    echo -e "${INFO} $NVIDIA_CONF already exists"
fi

# Configure bootloader
if [ -f /etc/default/grub ]; then
    echo -e "${NOTE} Configuring GRUB..."
    
    # Add nvidia-drm.modeset=1
    if ! sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
        echo -e "${OK} Added nvidia-drm.modeset=1 to GRUB"
    fi
    
    # Add nvidia_drm.fbdev=1
    if ! sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
        sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.fbdev=1"/' /etc/default/grub
        echo -e "${OK} Added nvidia_drm.fbdev=1 to GRUB"
    fi
    
    # Regenerate GRUB config
    sudo grub-mkconfig -o /boot/grub/grub.cfg >> "$LOG" 2>&1
    echo -e "${OK} GRUB configuration updated"
    
elif [ -f /boot/loader/loader.conf ]; then
    echo -e "${NOTE} Configuring systemd-boot..."
    
    find /boot/loader/entries/ -type f -name "*.conf" | while read imgconf; do
        if ! grep -q "nvidia-drm.modeset=1" "$imgconf"; then
            # Backup
            sudo cp "$imgconf" "${imgconf}.bak"
            
            # Add NVIDIA options
            sdopt=$(grep -w "^options" "$imgconf" | sed 's/\b nvidia-drm.modeset=[^ ]*\b//g' | sed 's/\b nvidia_drm.fbdev=[^ ]*\b//g')
            sudo sed -i "/^options/c${sdopt} nvidia-drm.modeset=1 nvidia_drm.fbdev=1" "$imgconf" >> "$LOG" 2>&1
            
            echo -e "${OK} Updated $imgconf"
        fi
    done
fi

# Create environment variables for Hyprland
ENV_CONF="$HOME/.config/hypr/nvidia.conf"
cat > "$ENV_CONF" << 'EOF'
# ═══════════════════════════════════════════════════════════
# NVIDIA Hyprland Environment Variables
# ═══════════════════════════════════════════════════════════

env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = WLR_NO_HARDWARE_CURSORS,1
env = NVD_BACKEND,direct

# Optional: Better cursor rendering
env = WLR_DRM_NO_ATOMIC,1
EOF

echo -e "${OK} Created NVIDIA environment config"

print_section "NVIDIA Setup Complete"
echo -e "${INFO} Please ${YELLOW}reboot${RESET} for changes to take effect"
echo -e "${INFO} After reboot, verify with: ${YELLOW}nvidia-smi${RESET}"
