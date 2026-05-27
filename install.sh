#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

APP_NAME="MasterDNS + 3x-ui"
APP_DIR="/opt/masterdns-3xui"
MASTERDNS_DIR="/opt/masterdnsvpn"
MANAGER_PATH="/usr/local/bin/masterdns-3xui"
MANAGER_URL="https://raw.githubusercontent.com/DarkPoesidon/Masterdns-3xui/main/masterdns-3xui"
MASTERDNS_INSTALL_URL="https://raw.githubusercontent.com/masterking32/MasterDnsVPN/main/server_linux_install.sh"
XUI_INSTALL_URL="https://raw.githubusercontent.com/MHSanaei/3x-ui/main/install.sh"

red=$'\033[0;31m'
green=$'\033[0;32m'
yellow=$'\033[0;33m'
blue=$'\033[0;34m'
plain=$'\033[0m'

info() { echo -e "${blue}[INFO]${plain} $*"; }
ok() { echo -e "${green}[OK]${plain} $*"; }
warn() { echo -e "${yellow}[WARN]${plain} $*"; }
die() { echo -e "${red}[ERROR]${plain} $*" >&2; exit 1; }

need_root() {
  [[ "${EUID}" -eq 0 ]] || die "Run as root: sudo bash install.sh"
}

confirm() {
  local prompt="${1:-Continue?}"
  local default="${2:-Y}"
  local ans
  read -r -p "${prompt} [${default}/n]: " ans
  ans="${ans:-$default}"
  [[ "$ans" == "y" || "$ans" == "Y" || "$ans" == "yes" || "$ans" == "YES" ]]
}

detect_pm() {
  if command -v apt-get >/dev/null 2>&1; then echo apt
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  elif command -v yum >/dev/null 2>&1; then echo yum
  elif command -v pacman >/dev/null 2>&1; then echo pacman
  elif command -v zypper >/dev/null 2>&1; then echo zypper
  elif command -v apk >/dev/null 2>&1; then echo apk
  else die "No supported package manager found."
  fi
}

install_base_deps() {
  local pm
  pm="$(detect_pm)"
  info "Installing required tools..."
  case "$pm" in
    apt)
      apt-get update
      apt-get install -y curl wget ca-certificates jq sqlite3 iproute2 lsof unzip tar openssl cron
      ;;
    dnf)
      dnf -y install curl wget ca-certificates jq sqlite iproute lsof unzip tar openssl cronie
      ;;
    yum)
      yum -y install curl wget ca-certificates jq sqlite iproute lsof unzip tar openssl cronie
      ;;
    pacman)
      pacman -Sy --noconfirm curl wget ca-certificates jq sqlite iproute2 lsof unzip tar openssl cronie
      ;;
    zypper)
      zypper refresh
      zypper -q install -y curl wget ca-certificates jq sqlite3-tools iproute2 lsof unzip tar openssl cron
      ;;
    apk)
      apk update
      apk add curl wget ca-certificates jq sqlite iproute2 lsof unzip tar openssl dcron
      ;;
  esac
  ok "Tools are ready."
}

install_manager() {
  mkdir -p "$APP_DIR/backups"
  if [[ -f "./masterdns-3xui" ]]; then
    install -m 0755 "./masterdns-3xui" "$MANAGER_PATH"
  else
    curl -fsSL "$MANAGER_URL" -o "$MANAGER_PATH"
    chmod 0755 "$MANAGER_PATH"
  fi
  ok "Manager installed: $MANAGER_PATH"
}

install_xui() {
  if command -v x-ui >/dev/null 2>&1 && systemctl list-unit-files 2>/dev/null | grep -q '^x-ui\.service'; then
    ok "3x-ui is already installed."
    return 0
  fi
  warn "The original 3x-ui installer will run now."
  warn "Keep SQLite unless you know you need PostgreSQL; automatic WARP setup uses SQLite."
  confirm "Install original 3x-ui panel now?" "Y" || return 0
  local tmp
  tmp="$(mktemp)"
  curl -fsSL "$XUI_INSTALL_URL" -o "$tmp"
  bash "$tmp"
  rm -f "$tmp"
}

install_masterdns() {
  if [[ -f /etc/systemd/system/masterdnsvpn.service ]] || systemctl cat masterdnsvpn >/dev/null 2>&1; then
    ok "MasterDnsVPN is already installed."
    return 0
  fi
  warn "MasterDnsVPN needs UDP/TCP port 53 and may disable local DNS stub services."
  confirm "Install MasterDnsVPN server now?" "Y" || return 0
  mkdir -p "$MASTERDNS_DIR"
  (
    cd "$MASTERDNS_DIR"
    local tmp
    tmp="$(mktemp)"
    curl -fsSL "$MASTERDNS_INSTALL_URL" -o "$tmp"
    bash "$tmp"
    rm -f "$tmp"
  )
}

show_finish() {
  cat <<EOF

${green}${APP_NAME} setup is ready.${plain}

Main command:
  sudo masterdns-3xui

Original 3x-ui admin menu:
  sudo x-ui

Useful service commands:
  sudo systemctl status x-ui
  sudo systemctl status masterdnsvpn
  sudo journalctl -u masterdnsvpn -f

WARP is optional and only applies to MasterDnsVPN from this manager.
Open the manager and choose:
  4) WARP / SOCKS for MasterDnsVPN only

Do not type menu numbers in the Linux shell. First run:
  sudo masterdns-3xui

Then choose the menu option inside that manager.
EOF
}

open_manager_now() {
  if [[ -x "$MANAGER_PATH" ]] && confirm "Open the combined manager now?" "Y"; then
    "$MANAGER_PATH"
  fi
}

main() {
  need_root
  echo -e "${green}${APP_NAME} installer${plain}"
  install_base_deps
  install_manager
  install_xui
  install_masterdns
  show_finish
  open_manager_now
}

main "$@"
