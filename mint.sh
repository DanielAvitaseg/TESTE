#!/bin/bash

# --- Início do Script de Instalação Otimizado para Linux Mint ---

# 1. Atualizar e instalar dependências essenciais
echo "✅ Atualizando a lista de pacotes e instalando dependências (curl, wget, gpg, apt-transport-https, software-properties-common, snapd)..."
sudo apt update
sudo apt install -y curl wget gpg apt-transport-https software-properties-common snapd

# 2. Configuração de Repositórios da Microsoft (para .NET, PowerShell, VSCode, Intune)
echo "✅ Configurando repositórios da Microsoft..."

# Baixar e registrar a chave GPG da Microsoft
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg

# Adicionar repositórios para o Mint
# Repositório VS Code
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# --- OTIMIZAÇÃO: Usar a base 22.04 (Jammy) para produtos MS, base mais comum no Mint 21+ ---
# Base do Mint 21 (Ubuntu 22.04 - Jammy)
OS_VERSION="ubuntu/22.04"

# Repositório .NET/.NET Core/PowerShell/Intune
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-${OS_VERSION/ubuntu\//} prod main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list > /dev/null
# --- FIM OTIMIZAÇÃO ---

sudo apt update

# 3. Instalação dos Programas

echo "🚀 Iniciando a instalação dos programas..."

# Docker Engine (docker.io) e Docker Compose
# O pacote docker.io do repositório do Mint/Ubuntu inclui o Docker Engine.
# Para garantir o Compose, instalamos explicitamente o pacote 'docker-compose-plugin'.
# O Mint/Ubuntu 22.04 (base do Mint 21) usa esse nome de pacote.
sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker "$USER"
echo ">> Docker e Docker Compose instalados. ⚠️ **Você precisará reiniciar a sessão (logout/login) para usar 'docker' e 'docker compose' sem 'sudo'.**"


# Slack (Usando Snap - o método mais confiável/atual)
sudo snap install slack --classic

# Postman (Usando Snap - o método mais simples)
sudo snap install postman

# VS Code (Usando o repositório da Microsoft)
sudo apt install -y code

# DBeaver (Usando Snap - o método mais simples)
sudo snap install dbeaver-ce

# PowerShell (Usando o repositório da Microsoft)
sudo apt install -y powershell

# .NET/Netcore (Instalando o SDK 8.0, o que inclui o runtime)
sudo apt install -y dotnet-sdk-8.0

# Intune Portal (Usando o repositório da Microsoft)
sudo apt install -y intune-portal

# 4. Instalação do NVM (Node Version Manager)
echo "🚀 Instalando NVM (Node Version Manager)..."
NVM_INSTALLER_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"
curl -o- "$NVM_INSTALLER_URL" | bash

# Detectar arquivo de perfil (Bash ou Zsh)
PROFILE_FILE="$HOME/.bashrc"
if [ -n "$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
fi

if ! grep -q 'NVM_DIR' "$PROFILE_FILE"; then
    echo "" >> "$PROFILE_FILE"
    echo "# Configuração do NVM adicionada pelo script de instalação" >> "$PROFILE_FILE"
    echo "export NVM_DIR=\"$HOME/.nvm\"" >> "$PROFILE_FILE"
    echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"  # This loads nvm" >> "$PROFILE_FILE"
    echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"  # This loads nvm bash_completion" >> "$PROFILE_FILE"
fi

echo ">> NVM instalado. ⚠️ **Você DEVE reabrir seu terminal ou rodar 'source $PROFILE_FILE' para usar o comando 'nvm'.**"

# 5. Configuração do Papel de Parede
echo "🖼️ Tentando configurar o papel de parede 'Novos-colaboradores-2-2.png'..."

# <<<<<<<<<<<< ATENÇÃO: Substitua o link abaixo pelo link de download direto da imagem >>>>>>>>>>>>
WALLPAPER_URL="[COLOQUE O LINK DIRETO PARA O ARQUIVO AQUI]" 
WALLPAPER_NAME="Novos-colaboradores-2-2.png"
WALLPAPER_PATH="$HOME/Imagens/$WALLPAPER_NAME"

# Se o link for válido, descomente a linha abaixo para baixar:
# wget -O "$WALLPAPER_PATH" "$WALLPAPER_URL"

DOWNLOADS_PATH="$HOME/Downloads/$WALLPAPER_NAME"
if [ -f "$DOWNLOADS_PATH" ]; then
    cp "$DOWNLOADS_PATH" "$WALLPAPER_PATH"
    echo "Papel de parede copiado da pasta Downloads."
elif [ ! -f "$WALLPAPER_PATH" ]; then
    echo "❌ ERRO: Não foi possível encontrar o papel de parede. Link direto não fornecido ou arquivo ausente em $DOWNLOADS_PATH."
fi

# Configurar o papel de parede
if [ -f "$WALLPAPER_PATH" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
    echo "Papel de parede configurado (pode precisar reiniciar a sessão para ver a mudança)."
fi

# --- Fim do Script ---
echo ""
echo "--- 🥳 Instalação Concluída ---"
echo "Programas instalados: **Docker, Docker Compose**, DBeaver, Intune Portal, .NET SDK, NVM, Postman, PowerShell, Slack, VS Code."
echo ""
echo "🌟 **PRÓXIMOS PASSOS OBRIGATÓRIOS** 🌟"
echo "1. **Reinicie a sessão (logout/login)** para o **Docker e Docker Compose** funcionarem sem 'sudo'."
echo "2. Para usar o **NVM**, abra um novo terminal ou rode:"
echo "   source $PROFILE_FILE"
echo "   ...e depois 'nvm install node' para instalar o Node.js."
echo "3. Verifique a configuração do Intune Portal."
