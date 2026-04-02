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

# ─── Step 0: GitHub PAT setup ────────────────────────────────────────────────
echo ""
echo "=== GitHub Personal Access Token Setup ==="
echo ""
echo "Please generate a fine-grained GitHub PAT at the following URL:"
echo "  https://github.com/settings/personal-access-tokens/new"
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
ENV_FILE="$HOME/.env"
# Remove any existing GITHUB_TOKEN line then append
if [[ -f "$ENV_FILE" ]]; then
  sed -i '/^export GITHUB_TOKEN=/d' "$ENV_FILE"
fi
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

# Set up git-askpass
cat > "$HOME/git-askpass.sh" <<'EOF'
#!/bin/sh
case "$1" in
  *Username*) echo "bradley-z" ;;
  *Password*) echo "$GITHUB_TOKEN" ;;
esac
EOF
chmod 700 "$HOME/git-askpass.sh"

export GIT_ASKPASS="$HOME/git-askpass.sh"
export GITHUB_TOKEN="${GITHUB_PAT}"

# Persist GIT_ASKPASS in .env as well
if grep -q '^export GIT_ASKPASS=' "$ENV_FILE" 2>/dev/null; then
  sed -i '/^export GIT_ASKPASS=/d' "$ENV_FILE"
fi
echo "export GIT_ASKPASS=\"\$HOME/git-askpass.sh\"" >> "$ENV_FILE"

echo "git-askpass configured."

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
  # Make uv available in the current session
  export PATH="$HOME/.local/bin:$PATH"
  echo "uv installed: $(uv --version)"
else
  echo "uv already installed: $(uv --version)"
fi

echo ""
echo "Setup complete. Re-source your shell rc or run: source ~/.env"
