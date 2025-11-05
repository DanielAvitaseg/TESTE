#!/usr/bin/env bash
set -euo pipefail

UBUNTU_CODENAME=$(grep UBUNTU_CODENAME /etc/os-release | cut -d'=' -f2)
ARCH=$(dpkg --print-architecture)

echo "Atualizando pacotes..."
apt update -y
apt install -y ca-certificates curl gnupg apt-transport-https lsb-release software-properties-common

# -------------------------
# Docker
# -------------------------
echo "Config Docker..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor > /etc/apt/keyrings/docker.gpg
chmod 644 /etc/apt/keyrings/docker.gpg

echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" \
  > /etc/apt/sources.list.d/docker.list

# -------------------------
# VS Code (fix definitivo)
# -------------------------
echo "Reset VS Code..."
rm -f /etc/apt/sources.list.d/vscode.list
rm -f /etc/apt/sources.list.d/code.list
rm -f /etc/apt/sources.list.d/*microsoft*.list
rm -f /etc/apt/trusted.gpg.d/microsoft.gpg
rm -f /usr/share/keyrings/microsoft.gpg
rm -f /etc/apt/keyrings/microsoft.gpg

mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg
chmod 644 /etc/apt/keyrings/microsoft.gpg

echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  > /etc/apt/sources.list.d/vscode.list

# -------------------------
# DBeaver CE
# -------------------------
echo "Config DBeaver..."
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor > /etc/apt/keyrings/dbeaver.gpg
chmod 644 /etc/apt/keyrings/dbeaver.gpg

echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" \
  > /etc/apt/sources.list.d/dbeaver.list

# -------------------------
# Instalação
# -------------------------
echo "Instalando pacotes..."
apt update -y
apt install -y docker-ce docker-ce-cli docker-compose-plugin code dbeaver-ce

# -------------------------
# Grupo docker
# -------------------------
if ! groups "$SUDO_USER" | grep -q docker; then
  usermod -aG docker "$SUDO_USER"
  echo "Usuário adicionado ao grupo docker. Re-login necessário."
fi

echo "Concluído."
