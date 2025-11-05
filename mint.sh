#!/bin/bash

# --- Início do Script de Instalação Simplificado para Linux Mint ---

# 1. Atualizar e instalar dependências essenciais
echo "Atualizando a lista de pacotes e instalando dependências (curl, wget, gpg, apt-transport-https, software-properties-common, snapd)..."
sudo apt update
sudo apt install -y curl wget gpg apt-transport-https software-properties-common snapd

# 2. Configuração de Repositórios da Microsoft (para .NET, PowerShell, VSCode, Intune)
echo "Configurando repositórios da Microsoft..."
# Baixar e registrar a chave GPG da Microsoft
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg

# Adicionar repositórios para o Mint (baseado em Ubuntu)
# Repositório VS Code
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
# Repositório .NET/.NET Core (usando o do Ubuntu 22.04 LTS, que é a base recente do Mint)
source /etc/os-release
if [[ "$VERSION_ID" == "21" ]]; then
    # Baseado em Ubuntu 22.04
    OS_VERSION="ubuntu/22.04"
elif [[ "$VERSION_ID" == "20" ]]; then
    # Baseado em Ubuntu 20.04
    OS_VERSION="ubuntu/20.04"
else
    # Tentativa de versão genérica ou baseada em 22.04
    OS_VERSION="ubuntu/22.04"
fi
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-${OS_VERSION/ubuntu\//} prod main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list > /dev/null

sudo apt update

# 3. Instalação dos Programas

echo "Iniciando a instalação dos programas..."

# Docker (Usando o pacote docker.io do repositório padrão)
# Adiciona o usuário atual ao grupo 'docker' para rodar sem 'sudo'
sudo apt install -y docker.io
sudo usermod -aG docker "$USER"
echo ">> Docker instalado. **Você precisará reiniciar a sessão (logout/login) para usar 'docker' sem 'sudo'.**"

# Slack (Usando Snap - o método mais confiável/atual)
sudo snap install slack --classic

# Postman (Usando Snap - o método mais simples)
sudo snap install postman

# VS Code (Usando o repositório da Microsoft)
sudo apt install -y code

# DBeaver (Usando Snap - o método mais simples)
# Alternativa: sudo add-apt-repository ppa:serge-rider/dbeaver-ce -y && sudo apt update && sudo apt install -y dbeaver-ce
sudo snap install dbeaver-ce

# PowerShell (Usando o repositório da Microsoft)
sudo apt install -y powershell

# .NET/Netcore (Instalando o SDK 8.0, o que inclui o runtime)
# Mude 'dotnet-sdk-8.0' para a versão que você preferir (ex: 6.0, 7.0)
sudo apt install -y dotnet-sdk-8.0

# Intune Portal (Usando o repositório da Microsoft)
# Note: A instalação requer que você complete o processo de login após a instalação.
sudo apt install -y intune-portal

# 4. Instalação do NVM (Node Version Manager)
echo "Instalando NVM (Node Version Manager)..."
# O script de instalação oficial é usado
NVM_INSTALLER_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"
curl -o- "$NVM_INSTALLER_URL" | bash

# Adicionar linhas de carregamento do NVM aos arquivos de shell (se não existirem)
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

echo ">> NVM instalado. **Você DEVE reabrir seu terminal ou rodar 'source $PROFILE_FILE' para usar o comando 'nvm'.**"

# 5. Configuração do Papel de Parede
echo "Tentando configurar o papel de parede 'Novos-colaboradores-2-2.png'..."
WALLPAPER_URL="[COLOQUE O LINK DIRETO PARA O ARQUIVO AQUI]" # <--- Mude esta URL para o link direto!
WALLPAPER_NAME="Novos-colaboradores-2-2.png"
WALLPAPER_PATH="$HOME/Imagens/$WALLPAPER_NAME"

# Se você souber o link de download direto:
# wget -O "$WALLPAPER_PATH" "$WALLPAPER_URL"

# Alternativamente, se você já tiver o arquivo na pasta Downloads
DOWNLOADS_PATH="$HOME/Downloads/$WALLPAPER_NAME"
if [ -f "$DOWNLOADS_PATH" ]; then
    cp "$DOWNLOADS_PATH" "$WALLPAPER_PATH"
    echo "Papel de parede copiado da pasta Downloads."
elif [ ! -f "$WALLPAPER_PATH" ]; then
    # Se você não tiver o link direto, o script não conseguirá baixar automaticamente
    echo "ERRO: Não foi possível encontrar o papel de parede em $DOWNLOADS_PATH e o link direto não foi fornecido."
    echo "Por favor, baixe 'Novos-colaboradores-2-2.png' manualmente para $HOME/Imagens/ e configure-o."
fi

# Configurar o papel de parede (comando dconf/gsettings é o padrão para Mint/Cinnamon)
if [ -f "$WALLPAPER_PATH" ]; then
    # Tenta definir o papel de parede no Mint (Cinnamon/Gnome based)
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
    gsettings set org.gnome.desktop.background picture-options 'zoom' # ou 'scaled'
    echo "Papel de parede configurado (pode precisar reiniciar a sessão para ver a mudança)."
fi

# --- Fim do Script ---
echo ""
echo "--- Instalação Concluída ---"
echo "Programas instalados: DBeaver, Docker, Intune Portal, .NET SDK, NVM, Postman, PowerShell, Slack, VS Code."
echo ""
echo "1. Lembre-se de **reiniciar a sessão (logout/login)** para o **Docker** e o **NVM** funcionarem corretamente."
echo "2. Para usar o **NVM**, abra um novo terminal ou rode 'source $PROFILE_FILE' e então use 'nvm install node' para instalar a versão mais recente do Node.js."
echo "3. O **Intune Portal** pode precisar de configuração inicial após a primeira execução."
