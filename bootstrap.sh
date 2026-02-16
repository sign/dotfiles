#!/usr/bin/env zsh

cd "$(dirname "${0}")";

git pull origin main;

# Install Oh My Zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme if not present
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    echo "Installing Powerlevel10k theme..."
    git clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Set ZSH_THEME in .zshrc if not already set to powerlevel10k
if [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
        if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
            sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        else
            echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
        fi
    fi
fi

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".idea" \
		--exclude ".DS_Store" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
	source ~/.zshrc;
}

if [[ "$1" == "--force" || "$1" == "-f" ]]; then
	doIt;
else
	read "REPLY?This may overwrite existing files in your home directory. Are you sure? (y/n) ";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;

./brew.sh

# Ensure brew-installed tools are available in this session
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# GitHub CLI auth
if ! gh auth status &> /dev/null; then
    echo "GitHub CLI not authenticated. Running gh auth login..."
    gh auth login
fi
gh auth setup-git

# Google Cloud SDK setup
if command -v gcloud &> /dev/null; then
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q .; then
        echo "Setting up Google Cloud SDK..."
        gcloud init
        gcloud auth login
    fi
fi

# 1Password CLI check
if command -v op &> /dev/null; then
    if ! op account list &> /dev/null; then
        echo ""
        echo "=== 1Password Setup Required ==="
        echo "1. Open 1Password and sign in with your email address"
        echo "2. Install the 1Password browser extension for Chrome"
        echo "3. Open 1Password (Mac app) Settings"
        echo "4. Go to Developer"
        echo "5. Enable 'Integrate with 1Password CLI'"
        echo "================================"
        echo ""
    fi
fi

echo ""
echo "Setup complete!"
echo ""
echo "NOTE: Open a new terminal for all PATH changes to take effect."
