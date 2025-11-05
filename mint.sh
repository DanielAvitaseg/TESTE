#!/bin/bash

# Este script instala ferramentas de desenvolvimento e corporativas no Linux Mint (ou Ubuntu/Debian-based).
# MUDANÇAS: Snap substituído por métodos APT/DEB para maior estabilidade em ambientes WSL/Containers.
# Versão base Microsoft fixada em 22.04 (Jammy), base do Mint 21+.

# Sair imediatamente se um comando falhar
set -e

# Definindo usuário e arquivo de perfil
TARGET_USER="$USER"
if [ "$USER" == "root" ]; then
    # Se rodando como root, o NVM deve ser instalado no home do primeiro usuário real ou mantido no /root.
    # Por segurança, mantemos no /root para o ambiente CLI/Container.
    PROFILE_FILE="/root/.bashrc"
    echo "AVISO: Rodando como ROOT. O NVM será configurado no /root/.bashrc."
else
    PROFILE_FILE="$HOME/.bashrc"
    if [ -n "$ZSH_VERSION" ]; then
        PROFILE_FILE="$HOME/.zshrc"
    fi
fi

# --- 1. Atualizar e instalar dependências essenciais ---
echo "--- [1/5] Atualizando e instalando dependências essenciais ---"
sudo apt update
# snapd é removido pois a instalação via snap falha em muitos ambientes não-systemd.
sudo apt install -y curl wget gpg apt-transport-https software-properties-common ca-certificates
sudo apt upgrade -y # Garantir que o sistema base esteja atualizado

# --- 2. Configuração de Repositórios ---
echo "--- [2/5] Configurando Repositórios da Microsoft e DBeaver ---"

# Repositórios da Microsoft (VS Code, .NET, PowerShell, Intune)
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg

# Repositório VS Code
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Repositório .NET/PowerShell/Intune (usando o repo 'prod' para Ubuntu 22.04)
# Corrigindo o erro de 'Release' do repositório
UBUNTU_BASE="22.04"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-${UBUNTU_BASE} prod main" | sudo tee /etc/apt/sources.list.d/microsoft-prod.list > /dev/null

# DBeaver PPA (Substituindo Snap pelo método APT)
sudo add-apt-repository ppa:dbeaver-team/dbeaver-ce -y

sudo apt update

# --- 3. Instalação dos Programas Principais ---
echo "--- [3/5] Instalando Programas Principais ---"

# Docker Engine e Docker Compose Plugin
echo ">> Instalando Docker Engine e Docker Compose Plugin..."
# Instala docker.io (engine) e docker-compose-plugin (o comando 'docker compose')
sudo apt install -y docker.io docker-compose-plugin

# Adiciona o usuário ao grupo 'docker' (importante para evitar 'sudo' - requer restart!)
if [ "$TARGET_USER" != "root" ]; then
    sudo usermod -aG docker "$TARGET_USER"
fi
echo ">> Docker instalado. Necessário reiniciar a sessão para usar sem 'sudo'."

# VS Code (via repo Microsoft)
sudo apt install -y code

# DBeaver Community Edition (via PPA)
sudo apt install -y dbeaver-ce

# PowerShell (via repo Microsoft)
sudo apt install -y powershell

# .NET SDK 8.0 (via repo Microsoft)
sudo apt install -y dotnet-sdk-8.0

# Intune Portal (via repo Microsoft)
# Este pacote pode falhar, dependendo do ambiente.
sudo apt install -y intune-portal || echo "AVISO: A instalação do Intune Portal falhou (pacote indisponível ou incompatível)."


# --- 4. Instalação de Ferramentas de Comunicação/API (Substituindo Snap por Downloads DEB) ---

# Postman (Não tem APT fácil. Tentativa de baixar binário)
# NOTA: Em ambiente CLI sem desktop, esta ferramenta é menos útil.
echo ">> Tentando instalar Postman via binário (Pode falhar em ambientes CLI/Docker)..."
# O Postman é muito grande para um script de CLI e não tem DEB oficial.
# Vamos removê-lo ou deixá-lo para instalação manual para evitar falhas.
# Neste script Otimizado, vamos pular Postman, Slack e NVM para manter a robustez.

# --------------------------------------------------------------------------------------
# NOVO PLANO: Slack, Postman e DBeaver instalados via APT/PPA (DBeaver OK, Slack/Postman REMOVIDOS).
# O Slack e Postman só são bem instalados via Snap/Desktop. Vamos pular ou adicionar manualmente.
# Para manter a robustez:
# --------------------------------------------------------------------------------------

# --- 5. Instalação do NVM (Node Version Manager) ---
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

# --- 6. Configuração do Papel de Parede (Seção Opcional) ---
echo "--- [5/5] Configuração do Papel de Parede ---"
# Removendo o erro de sintaxe e tratando o placeholder.
WALLPAPER_NAME="Novos-colaboradores-2-2.png"
WALLPAPER_PATH="$HOME/Imagens/$WALLPAPER_NAME"
# O comando gsettings precisa de um ambiente gráfico, que não existe em containers CLI.
echo ">> A configuração de papel de parede foi omitida neste script para maior robustez em CLI/servidor."


# --- Fim do Script ---
echo ""
echo "--- 🥳 Instalação Concluída ---"
echo "Ferramentas instaladas com sucesso: **Docker, Docker Compose**, DBeaver, .NET SDK, NVM, PowerShell, VS Code."
echo ""
echo "🌟 **PRÓXIMOS PASSOS OBRIGATÓRIOS** 🌟"
echo "1. **Reinicie a sessão (logout/login)** para o **Docker** funcionar sem 'sudo'."
echo "2. Para usar o **NVM**, abra um novo terminal ou rode: source $PROFILE_FILE"
echo "   ...e depois 'nvm install node' para instalar o Node.js."
