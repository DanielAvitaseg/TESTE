#!/bin/bash
# Script para instalar Docker Compose, NVM e definir papel de parede no Linux
# Uso: sudo bash setup_env.sh

set -e

echo "==> Atualizando pacotes..."
sudo apt update -y
sudo apt install -y curl ca-certificates gnupg lsb-release wget

# -------------------------------
# Instalar Docker Compose
# -------------------------------
echo "==> Instalando Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Docker Compose versão:"
docker-compose --version

# -------------------------------
# Instalar NVM (Node Version Manager)
# -------------------------------
echo "==> Instalando NVM..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi

# Ativar NVM no shell atual
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "NVM versão:"
nvm --version

# -------------------------------
# Definir papel de parede
# -------------------------------
echo "==> Definindo papel de parede..."
WALLPAPER_URL="https://i.ibb.co/cwtDVCS/Frame-6.png"
WALLPAPER_PATH="$HOME/Pictures/wallpaper.png"

mkdir -p "$HOME/Pictures"
wget -q "$WALLPAPER_URL" -O "$WALLPAPER_PATH"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
  gsettings set org.gnome.desktop.background picture-options "scaled"
elif command -v xfconf-query >/dev/null 2>&1; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$WALLPAPER_PATH"
else
  echo "Ambiente gráfico não suportado automaticamente. Configure o papel de parede manualmente."
fi

echo "==> Instalação e configuração concluídas."
