#!/usr/bin/env bash
# install_all.sh
# One-shot installer for Seeker lab (Debian/Ubuntu)
# Usage:
#   sudo ./install_all.sh           # interactive (asks)
#   sudo ./install_all.sh --yes     # non-interactive, default choices
#   sudo ./install_all.sh --clone https://github.com/thewhiteh4t/seeker.git
#   sudo ./install_all.sh --ngrok-authtoken <TOKEN>
#
set -euo pipefail
IFS=$'\n\t'

REPO_URL="${1:-}"    # optional first arg: repo url
AUTO_YES=0
NGROK_TOKEN=""
INSTALL_SYSTEMD=0
CLONE_DIR="${PWD}/seeker"

# parse args (simple)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y) AUTO_YES=1; shift;;
    --clone) CLONE_DIR="${2:-$CLONE_DIR}"; shift 2;;
    --ngrok-authtoken) NGROK_TOKEN="${2:-}"; shift 2;;
    --systemd) INSTALL_SYSTEMD=1; shift;;
    --repo) REPO_URL="${2:-}"; shift 2;;
    --help|-h) echo "Usage: sudo $0 [--yes] [--repo <git-url>] [--ngrok-authtoken <token>] [--systemd]"; exit 0;;
    *) shift;;
  esac
done

# helper prompt
confirm() {
  if [[ "$AUTO_YES" -eq 1 ]]; then
    return 0
  fi
  read -rp "$1 [y/N]: " ans
  [[ "$ans" =~ ^[Yy] ]]
}

info(){ printf '\e[1;34m[INFO]\e[0m %s\n' "$*"; }
warn(){ printf '\e[1;33m[WARN]\e[0m %s\n' "$*"; }
err(){ printf '\e[1;31m[ERR]\e[0m %s\n' "$*"; exit 1; }

# must be run as root or with sudo
if [[ $EUID -ne 0 ]]; then
  warn "This script needs sudo privileges. Please run as root or with sudo."
  exec sudo bash "$0" "$@"
fi

info "Starting installer..."

# 1) update
info "Updating apt cache..."
apt update -y

# 2) install system packages (idempotent)
PKGS=(git python3 python3-pip python3-venv php php-cli php-curl php-xml curl unzip)
info "Installing system packages: ${PKGS[*]}"
DEBIAN_FRONTEND=noninteractive apt install -y "${PKGS[@]}"

# 3) optional node (for localtunnel) - ask user
if confirm "Install nodejs + npm (needed for localtunnel) ?"; then
  info "Installing nodejs & npm (from apt)..."
  apt install -y nodejs npm
fi

# 4) clone repo if not exists
if [[ -n "${REPO_URL}" ]]; then
  info "Cloning repo ${REPO_URL} -> ${CLONE_DIR}"
  rm -rf "${CLONE_DIR}"
  git clone --depth 1 "${REPO_URL}" "${CLONE_DIR}"
elif [[ ! -d "${CLONE_DIR}" || ! -f "${CLONE_DIR}/seeker.py" ]]; then
  # no repo in cwd -> try official
  info "No repo found at ${CLONE_DIR}. Cloning default official repo..."
  rm -rf "${CLONE_DIR}"
  git clone --depth 1 https://github.com/thewhiteh4t/seeker.git "${CLONE_DIR}"
else
  info "Using existing directory ${CLONE_DIR}"
fi

cd "${CLONE_DIR}"

# 5) create venv
if [[ ! -d ".venv" ]]; then
  info "Creating python venv..."
  python3 -m venv .venv
else
  info "Virtualenv already exists - reusing .venv"
fi

# activate venv for pip installs
# shellcheck disable=SC1091
source .venv/bin/activate

# 6) upgrade pip & install python deps (safe list)
info "Upgrading pip and installing python libs..."
pip install --upgrade pip
pip install requests packaging psutil flask pyngrok

# 7) run repo provided install.sh to ensure system packages required by project are installed
if [[ -f install.sh ]]; then
  info "Running repository install.sh (system package helper)"
  # run non-interactive by passing through yes
  bash install.sh || warn "install.sh returned non-zero (check logs)"
fi

# 8) offer to set up ngrok (install binary) if token provided
if [[ -n "${NGROK_TOKEN}" ]]; then
  info "Installing ngrok binary..."
  NGROK_BIN="/usr/local/bin/ngrok"
  if [[ ! -x "${NGROK_BIN}" ]]; then
    curl -sSL -o /tmp/ngrok.zip "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip"
    unzip -o /tmp/ngrok.zip -d /usr/local/bin
    chmod +x /usr/local/bin/ngrok
  fi
  info "Configuring ngrok authtoken..."
  /usr/local/bin/ngrok authtoken "${NGROK_TOKEN}" || warn "ngrok authtoken failed"
fi

# 9) optional: create systemd service file to run seeker as service
if [[ "${INSTALL_SYSTEMD}" -eq 1 ]]; then
  SERVICE_NAME="seeker.service"
  SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}"
  info "Creating systemd service ${SERVICE_PATH}"
  cat > "${SERVICE_PATH}" <<'SERVICE_EOF'
[Unit]
Description=Seeker service (security lab)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=%h/seeker
ExecStart=%h/seeker/.venv/bin/python %h/seeker/seeker.py
Restart=on-failure
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
SERVICE_EOF

  systemctl daemon-reload
  systemctl enable --now "${SERVICE_NAME}" || warn "Failed to enable/start service"
  info "systemd service created and started (if permissions allowed)."
fi

# 10) final summary
info "Installation complete."
info "Repo directory: ${CLONE_DIR}"
info "Activate venv: cd ${CLONE_DIR} && source .venv/bin/activate"
info "Run Seeker: python3 seeker.py  (or use -h for options)"
if [[ -n "${NGROK_TOKEN}" ]]; then
  info "You can run: ngrok http 8080 (ngrok installed)"
else
  info "If you need HTTPS tunnel, consider installing ngrok or using localtunnel (npx localtunnel --port 8080)"
fi

exit 0
