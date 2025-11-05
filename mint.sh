#!/bin/bash

# Este script instala todas as ferramentas de desenvolvimento essenciais no Linux Mint.
# Método Otimizado: Prioriza APT/PPA para maior estabilidade em ambientes CLI/sem systemd (WSL, Containers).
# Programas: Docker, Docker Compose, VS Code, DBeaver, PowerShell, .NET SDK, NVM.

# Sair imediatamente se um comando falhar
set -e

# --- 0. Configurações de Ambiente ---
echo "--- [0/5] Configurando Variáveis de Ambiente ---"
TARGET_USER="$USER"
if [ "$USER" == "root" ]; then
    PROFILE_FILE="/root/.bashrc"
    echo "AVISO: Rodando como ROOT. O NVM será configurado no /root/.bashrc."
else
    PROFILE_FILE="$HOME/.bashrc"
    if [ -n "$ZSH_VERSION" ]; then
        PROFILE_FILE="$HOME/.zshrc"
    fi
fi
# Base do Mint 21+ (Ubuntu 22.04 - Jammy)
UBUNTU_BASE="22.04"

# --- 1. Atualizar e instalar dependências essenciais ---
echo "--- [1/5] Atualizando e instalando dependências essenciais (curl, gpg, software-properties-common) ---"
sudo apt update
sudo apt install -y curl wget gpg apt-transport-https software-properties-common ca-certificates
sudo apt upgrade -y

# --- 2. Configuração de Repositórios ---
echo "--- [2/5] Configurando Repositórios da Microsoft e DBeaver PPA ---"

# Chave GPG da Microsoft
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg

# Repositório VS Code
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Repositório .NET/PowerShell/Intune
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-${UBUNTU_BASE} prod main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list > /dev/null

# DBeaver PPA (Substituindo o Snap)
sudo add-apt-repository ppa:dbeaver-team/dbeaver-ce -y

sudo apt update

# --- 3. Instalação dos Programas Principais ---
echo "--- [3/5] Instalando Programas Principais (Docker, VS Code, DBeaver, .NET, PowerShell) ---"

# Docker Engine e Docker Compose Plugin
echo ">> Instalando Docker Engine e Docker Compose Plugin..."
sudo apt install -y docker.io docker-compose-plugin

# Adiciona o usuário ao grupo 'docker' (REQUER REINÍCIO DE SESSÃO)
if [ "$TARGET_USER" != "root" ]; then
    sudo usermod -aG docker "$TARGET_USER"
fi
echo ">> Docker e Docker Compose instalados. **Acesso sem 'sudo' REQUER REINÍCIO de sessão!**"

# VS Code (via repo Microsoft)
sudo apt install -y code

# DBeaver Community Edition (via PPA)
sudo apt install -y dbeaver-ce

# PowerShell (via repo Microsoft)
sudo apt install -y powershell

# .NET SDK 8.0 (via repo Microsoft)
sudo apt install -y dotnet-sdk-8.0

# Intune Portal (Pode falhar em ambientes CLI)
sudo apt install -y intune-portal || echo "AVISO: A instalação do Intune Portal falhou (pacote indisponível ou incompatível)."


# --- 4. Instalação do NVM (Node Version Manager) ---
echo "--- [4/5] Instalando NVM (Node Version Manager) ---"
NVM_INSTALLER_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"
curl -o- "$NVM_INSTALLER_URL" | bash

# Adicionar linhas de carregamento do NVM
if ! grep -q 'NVM_DIR' "$PROFILE_FILE"; then
    echo "" >> "$PROFILE_FILE"
    echo "# Configuração do NVM adicionada pelo script de instalação" >> "$PROFILE_FILE"
    echo "export NVM_DIR=\"$HOME/.nvm\"" >> "$PROFILE_FILE"
    echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"  # This loads nvm" >> "$PROFILE_FILE"
    echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"  # This loads nvm bash_completion" >> "$PROFILE_FILE"
fi

echo ">> NVM instalado. Necessário rodar 'source $PROFILE_FILE' para usar."

# --- 5. Aviso Final (Papel de Parede Removido para Estabilidade) ---
echo "--- [5/5] Aviso Final e Próximos Passos ---"
echo "O papel de parede e as ferramentas que usavam Snap (Slack, Postman) foram omitidos para garantir a estabilidade em ambientes CLI."

# --- Fim do Script ---
echo ""
echo "--- 🥳 Instalação Concluída ---"
echo "Ferramentas instaladas com sucesso: **Docker, Docker Compose**, DBeaver, .NET SDK, NVM, PowerShell, VS Code."
echo ""
echo "🌟 **PRÓXIMOS PASSOS OBRIGATÓRIOS** 🌟"
echo "1. **Reinicie a sessão (logout/login)** para o **Docker e Docker Compose** funcionarem sem 'sudo'."
echo "2. Para usar o **NVM**, abra um novo terminal ou rode: source $PROFILE_FILE"
echo "   ...e depois 'nvm install node' para instalar a versão do Node.js."
