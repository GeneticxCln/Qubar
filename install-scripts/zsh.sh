#!/bin/bash
# ═══════════════════════════════════════════════════════════
# QUBAR - ZSH with Oh My Zsh Setup
# ═══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/global_functions.sh"

LOG="$LOG_DIR/install-$(date +%d-%H%M%S)_zsh.log"

zsh_pkgs=(
    zsh
    zsh-completions
    fzf
    lsd
)

print_section "ZSH Setup"

# Install packages
echo -e "${NOTE} Installing ZSH packages..."
for pkg in "${zsh_pkgs[@]}"; do
    install_package "$pkg" "$LOG"
done

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${NOTE} Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >> "$LOG" 2>&1
    echo -e "${OK} Oh My Zsh installed"
else
    echo -e "${INFO} Oh My Zsh already installed"
fi

# Install plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo -e "${NOTE} Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" >> "$LOG" 2>&1
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo -e "${NOTE} Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" >> "$LOG" 2>&1
fi

# Backup existing configs
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

# Create .zshrc
cat > "$HOME/.zshrc" << 'EOF'
# ═══════════════════════════════════════════════════════════
# QUBAR ZSH Configuration
# ═══════════════════════════════════════════════════════════

export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="agnoster"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    fzf
    colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# ═══════════════════════════════════════════════════════════
# ALIASES
# ═══════════════════════════════════════════════════════════

# Modern replacements
alias ls='lsd'
alias ll='lsd -la'
alias la='lsd -a'
alias lt='lsd --tree'
alias cat='bat 2>/dev/null || cat'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'

# System
alias update='yay -Syu'
alias cleanup='yay -Rns $(yay -Qdtq) 2>/dev/null'
alias ip='ip -c'

# Hyprland
alias hypr='Hyprland'
alias hc='nvim ~/.config/hypr/hyprland.conf'
alias hk='nvim ~/.config/hypr/modules/keybinds.conf'

# QuickShell
alias qs='quickshell'
alias qsr='quickshell --reload'

# ═══════════════════════════════════════════════════════════
# ENVIRONMENT
# ═══════════════════════════════════════════════════════════

export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='kitty'
export BROWSER='firefox'

# Path
export PATH="$HOME/.local/bin:$PATH"

# FZF colors
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# ═══════════════════════════════════════════════════════════
# PROMPT CUSTOMIZATION
# ═══════════════════════════════════════════════════════════

# Hide user@hostname if local
prompt_context() {
    if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"
    fi
}

# Startup message
echo "Welcome to $(hostname)! 🚀"
EOF

echo -e "${OK} Created .zshrc configuration"

# Set ZSH as default shell
current_shell=$(basename "$SHELL")
if [ "$current_shell" != "zsh" ]; then
    echo -e "${NOTE} Setting ZSH as default shell..."
    chsh -s "$(command -v zsh)" || {
        echo -e "${WARN} Failed to change shell. You can do it manually with: chsh -s $(command -v zsh)"
    }
fi

echo -e "${OK} ZSH setup complete!"
echo -e "${INFO} Start a new terminal to use ZSH"
