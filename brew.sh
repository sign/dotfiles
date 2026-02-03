#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Install Xcode Command Line Tools if not present
if ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "Please complete the Xcode CLI tools installation, then re-run this script."
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f /opt/homebrew/bin/brew ]]; then
        echo >> "$HOME/.zprofile"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Make sure we're using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# Directory tree visualization
brew install tree
# Terminal multiplexer
brew install tmux
# Watch file changes / rerun commands
brew install watch


### Networking / transfer

# Install `wget`
brew install wget
# HTTP/S, FTP, etc. (used everywhere)
brew install curl
# JSON processor
brew install jq
# Fast file sync
brew install rsync
# Cloud / remote sync
brew install rclone
# Modern OpenSSL (used by curl, git, python, postgres, etc.)
brew install openssl@3
# CA bundle for TLS verification
brew install ca-certificates

### Git / dev workflow

# Sign commits with GPG
brew install gnupg
# Git
brew install git
# Git Large File Storage
brew install git-lfs
# GitHub CLI
brew install gh

### Compression
# 7zip archive support
brew install p7zip
# XZ compression
brew install xz
# Zstandard compression
brew install zstd

### Media

# ImageMagick (image processing backbone)
brew install imagemagick
# FFmpeg (audio/video processing)
brew install ffmpeg

### Development runtimes etc

# Node.js runtime
brew install node
# Node version manager
brew install nvm
# pnpm package manager
brew install pnpm
# Bun runtime
brew install bun
# Pulumi IaC
brew install pulumi

### Frequently used casks

# 1Password CLI (secure secrets access)
brew install --cask 1password
brew install --cask 1password-cli
# Google Cloud SDK (gcloud, gsutil, bq)
brew install --cask google-cloud-sdk
# Alias cask (some setups expose this separately)
brew install --cask gcloud-cli
# Conda-based Python environment managers
brew install --cask miniconda
# Container / VM runtime for macOS (Docker replacement)
brew install --cask orbstack
# Claude Code CLI
brew install --cask claude-code
# Local LLM playground
brew install --cask lm-studio

### Productivity / Communication

brew install --cask google-chrome
brew install --cask notion
brew install --cask loom
brew install --cask slack
brew install --cask zoom

# Remove outdated versions from the cellar.
brew cleanup
