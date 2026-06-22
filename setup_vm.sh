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

# The non-root user that runs docker / that CI SSHes in as. Defaults to whoever
# is running this script. Override with DEPLOY_USER=... ./setup_vm.sh
DEPLOY_USER="${DEPLOY_USER:-$(whoami)}"

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

# ─── Step 3: ag (The Silver Searcher) ────────────────────────────────────────
if ! command -v ag &>/dev/null; then
  echo ""
  echo "=== Installing ag (The Silver Searcher) ==="
  sudo apt-get update -y
  sudo apt-get install -y silversearcher-ag
  echo "ag installed: $(ag --version | head -1)"
else
  echo "ag already installed: $(ag --version | head -1)"
fi

# ─── Step 4: fzf ─────────────────────────────────────────────────────────────
if ! command -v fzf &>/dev/null; then
  echo ""
  echo "=== Installing fzf ==="
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
else
  echo "fzf already installed: $(fzf --version)"
fi

# ─── Step 5: GitHub PAT setup ────────────────────────────────────────────────
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

# ─── Step 6: Clone dotfiles ──────────────────────────────────────────────────
echo ""
echo "=== Cloning dotfiles ==="
mkdir -p "$HOME/repos"
if [[ ! -d "$HOME/repos/dotfiles" ]]; then
  git clone https://github.com/bradley-z/dotfiles "$HOME/repos/dotfiles"
else
  echo "dotfiles already cloned, skipping."
fi

# ─── Step 7: Apply dotfiles ──────────────────────────────────────────────────
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

rm -rf "$HOME/repos/dotfiles"

# ─── Step 8: Docker ──────────────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  echo ""
  echo "=== Installing Docker ==="
  curl -fsSL https://get.docker.com | sh
  echo "Docker installed: $(docker --version)"
else
  echo "Docker already installed: $(docker --version)"
fi

# ─── Step 9: VPS shared stack (Caddy, sqlite3, ufw, fail2ban, auto-updates) ──
echo ""
echo "=== Installing VPS shared stack ==="
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y caddy sqlite3 ufw fail2ban unattended-upgrades

# ─── Step 10: Add deploy user to the docker group ────────────────────────────
echo ""
echo "=== Adding '$DEPLOY_USER' to the docker group ==="
sudo usermod -aG docker "$DEPLOY_USER"

# ─── Step 11: Caddy shared config ────────────────────────────────────────────
# Shared header snippet + auto-include of per-app vhosts from /etc/caddy/sites/.
echo ""
echo "=== Configuring Caddy ==="
sudo mkdir -p /etc/caddy/sites
sudo tee /etc/caddy/Caddyfile >/dev/null <<'EOF'
# Managed by setup_vm.sh. Per-app vhosts live in /etc/caddy/sites/<app>.caddy
# and are written by provision.sh — do not edit those by hand.

# Shared hardening applied by every app vhost via `import app-common`.
(app-common) {
	encode zstd gzip
	header {
		Strict-Transport-Security "max-age=31536000"
		X-Content-Type-Options "nosniff"
		X-Frame-Options "DENY"
		Referrer-Policy "no-referrer"
		-Server
	}
}

import /etc/caddy/sites/*.caddy
EOF
sudo systemctl reload caddy 2>/dev/null || sudo systemctl restart caddy

# ─── Step 12: Firewall (allow SSH + HTTP/HTTPS, deny the rest) ───────────────
echo ""
echo "=== Configuring firewall ==="
sudo ufw allow OpenSSH >/dev/null
sudo ufw allow 80,443/tcp >/dev/null
sudo ufw --force enable

# ─── Step 13: Unattended security upgrades ───────────────────────────────────
echo ""
echo "=== Enabling unattended security upgrades ==="
sudo dpkg-reconfigure -f noninteractive unattended-upgrades || true

echo ""
echo "Setup complete. Re-source your shell or open a new terminal to apply changes."
echo ""
echo "VPS ready. As '$DEPLOY_USER' (log out/in once so the docker group applies):"
echo "  docker login ghcr.io -u $DEPLOY_USER     # paste a classic PAT with read:packages"
echo "Then provision each app with ./provision.sh."
