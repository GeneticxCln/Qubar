#!/bin/bash
# ╔═══════════════════════════════════════════════════════════╗
# ║             Simple SDDM Theme Installation Script         ║
# ╚═══════════════════════════════════════════════════════════╝

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  Installing Simple SDDM Theme for Qubar"
echo "═══════════════════════════════════════════════════════════"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Install SDDM if not already installed
echo -e "${BLUE}[1/5] Checking SDDM installation...${NC}"
if ! command -v sddm &> /dev/null; then
    echo "SDDM not found. Installing..."
    pacman -S --noconfirm sddm qt6-svg qt6-declarative
else
    echo -e "${GREEN}SDDM already installed${NC}"
fi

# Create themes directory
echo -e "${BLUE}[2/5] Creating themes directory...${NC}"
mkdir -p /usr/share/sddm/themes

# Download Simple SDDM theme
echo -e "${BLUE}[3/5] Downloading Simple SDDM theme...${NC}"
cd /usr/share/sddm/themes

if [ -d "simple-sddm" ]; then
    echo "Theme already exists, updating..."
    cd simple-sddm
    git pull
    cd ..
else
    git clone https://github.com/simple-sddm/simple-sddm.git
fi

# Copy SDDM configuration
echo -e "${BLUE}[4/5] Configuring SDDM...${NC}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp "$SCRIPT_DIR/sddm.conf" /etc/sddm.conf.d/sddm.conf 2>/dev/null || {
    mkdir -p /etc/sddm.conf.d
    cp "$SCRIPT_DIR/sddm.conf" /etc/sddm.conf.d/sddm.conf
}

# Enable SDDM service
echo -e "${BLUE}[5/5] Enabling SDDM service...${NC}"
systemctl enable sddm.service

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Simple SDDM Theme installed successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "1. Customize the theme (optional):"
echo "   Edit: /usr/share/sddm/themes/simple-sddm/theme.conf"
echo ""
echo "2. Reboot to see the login screen:"
echo "   sudo reboot"
echo ""
echo "3. To test SDDM without rebooting:"
echo "   sudo systemctl start sddm"
echo ""
