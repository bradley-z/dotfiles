#!/usr/bin/env bash
set -e

# Verify ubuntu and curl exist
if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
  echo "Error: This script requires Ubuntu." >&2
  exit 1
fi

if ! command -v curl &>/dev/null; then
  echo "Error: curl is required but not installed." >&2
  exit 1
fi

# ─── Step 1: tmux ────────────────────────────────────────────────────────────
if ! command -v tmux &>/dev/null; then
  echo ""
  echo "=== Installing tmux ==="
  sudo apt-get update -y
  sudo apt-get install -y tmux
  echo "tmux installed: $(tmux -V)"
else
  echo "tmux already installed: $(tmux -V)"
fi

# ─── Step 2: uv ──────────────────────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  echo ""
  echo "=== Installing uv ==="
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  echo "uv installed: $(uv --version)"
else
  echo "uv already installed: $(uv --version)"
fi

# ─── Step 3: fzf ─────────────────────────────────────────────────────────────
if ! command -v fzf &>/dev/null; then
  echo ""
  echo "=== Installing fzf ==="
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
else
  echo "fzf already installed: $(fzf --version)"
fi

# ─── Step 4: GitHub PAT setup ────────────────────────────────────────────────
ENV_FILE="$HOME/.env"

if [[ -n "$GITHUB_TOKEN" ]]; then
  echo "GITHUB_TOKEN already set, skipping PAT setup."
else
  echo ""
  echo "=== GitHub Personal Access Token Setup ==="
  echo ""
  echo "Please generate a fine-grained GitHub PAT at the following URL:"
  echo "  https://github.com/settings/tokens/new"
  echo ""
  echo "Grant read-only access to whichever repositories you need, then paste the token below."
  echo ""
  read -rsp "Paste your GitHub PAT: " GITHUB_PAT
  echo ""

  if [[ -z "$GITHUB_PAT" ]]; then
    echo "Error: No token provided." >&2
    exit 1
  fi

  # Write token to .env
  sed -i '/^export GITHUB_TOKEN=/d' "$ENV_FILE" 2>/dev/null || true
  echo "export GITHUB_TOKEN='${GITHUB_PAT}'" >> "$ENV_FILE"
  echo "Saved GITHUB_TOKEN to $ENV_FILE"

  # Source .env from the appropriate shell rc file
  for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$RC" ]]; then
      if ! grep -q 'source.*\.env' "$RC" && ! grep -q '\. .*\.env' "$RC"; then
        echo "" >> "$RC"
        echo '# Load environment variables' >> "$RC"
        echo 'if [ -f "$HOME/.env" ]; then source "$HOME/.env"; fi' >> "$RC"
        echo "Updated $RC to source $ENV_FILE"
      fi
    fi
  done

  export GITHUB_TOKEN="${GITHUB_PAT}"
fi

# ─── Step 5: Clone dotfiles ──────────────────────────────────────────────────
echo ""
echo "=== Cloning dotfiles ==="
mkdir -p "$HOME/repos"
if [[ ! -d "$HOME/repos/dotfiles" ]]; then
  git clone https://github.com/bradley-z/dotfiles "$HOME/repos/dotfiles"
else
  echo "dotfiles already cloned, skipping."
fi

# ─── Step 6: Apply dotfiles ──────────────────────────────────────────────────
echo ""
echo "=== Applying dotfiles ==="

cp "$HOME/repos/dotfiles/git-askpass.sh" "$HOME/.git-askpass.sh"
chmod 700 "$HOME/.git-askpass.sh"
sed -i '/^export GIT_ASKPASS=/d' "$ENV_FILE" 2>/dev/null || true
echo "export GIT_ASKPASS=\"\$HOME/.git-askpass.sh\"" >> "$ENV_FILE"
echo "Copied git-askpass.sh -> ~/.git-askpass.sh"

cp "$HOME/repos/dotfiles/functions.sh" "$HOME/.functions.sh"
echo "Copied functions.sh -> ~/.functions.sh"

cp "$HOME/repos/dotfiles/tmux.conf" "$HOME/.tmux.conf"
echo "Copied tmux.conf -> ~/.tmux.conf"

# Source .functions.sh from shell rc files
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$RC" ]]; then
    if ! grep -q '\.functions\.sh' "$RC"; then
      echo "" >> "$RC"
      echo '# Load shell functions and aliases' >> "$RC"
      echo 'if [ -f "$HOME/.functions.sh" ]; then source "$HOME/.functions.sh"; fi' >> "$RC"
      echo "Updated $RC to source ~/.functions.sh"
    fi
  fi
done

echo ""
echo "Setup complete. Re-source your shell or open a new terminal to apply changes."
