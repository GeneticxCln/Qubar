#!/bin/bash
# ╔═══════════════════════════════════════════════════════════╗
# ║              Qubar Configuration Backup Script            ║
# ║          Creates timestamped backup of all configs        ║
# ╚═══════════════════════════════════════════════════════════╝

set -euo pipefail

# Backup directory
BACKUP_DIR="${HOME}/qubar-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/qubar-backup-${TIMESTAMP}.tar.gz"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "═══════════════════════════════════════════════════════════"
echo "  Qubar Configuration Backup"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# List of directories to backup
CONFIGS=(
    "$HOME/.config/quickshell"
    "$HOME/.config/hypr"
    "$HOME/.config/swaylock"
    "$HOME/.config/sddm"
    "$HOME/.config/swappy"
    "$HOME/.config/wlogout"
    "$HOME/Qubar"
)

# Filter existing directories
EXISTING_CONFIGS=()
for config in "${CONFIGS[@]}"; do
    if [ -d "$config" ]; then
        EXISTING_CONFIGS+=("$config")
    fi
done

if [ ${#EXISTING_CONFIGS[@]} -eq 0 ]; then
    echo -e "${BLUE}No config directories found to backup${NC}"
    exit 0
fi

echo "Backing up the following directories:"
printf ' - %s\n' "${EXISTING_CONFIGS[@]}"
echo ""

# Create backup
echo -e "${BLUE}Creating backup...${NC}"
if tar -czf "$BACKUP_FILE" "${EXISTING_CONFIGS[@]}" 2>/dev/null; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}Backup created successfully!${NC}"
    echo ""
    echo "Location: $BACKUP_FILE"
    echo "Size: $BACKUP_SIZE"
    echo ""
    
    # Keep only last 5 backups
    BACKUP_COUNT=$(find "$BACKUP_DIR" -maxdepth 1 -name 'qubar-backup-*.tar.gz' -type f 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 5 ]; then
        echo "Cleaning up old backups (keeping last 5)..."
        find "$BACKUP_DIR" -maxdepth 1 -name 'qubar-backup-*.tar.gz' -type f -printf '%T@ %p\n' | sort -n | head -n -5 | cut -d' ' -f2- | xargs -r rm -f
    fi
    
    echo -e "${GREEN}Done!${NC}"
else
    echo "Error creating backup"
    exit 1
fi
