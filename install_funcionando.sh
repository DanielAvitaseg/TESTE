#!/bin/bash
# Script de Instalação Unificado e Auto-Verificação para Ferramentas de Desenvolvimento
# Autor: Adaptado de DanielAvitaseg e Unificado pelo Assistente Gemini
# Usuário de Destino: victorpersike

# Variável que armazena o nome de usuário do sistema (deve ser 'victorpersike' no seu caso)
TARGET_USER="victorpersike"
HOME_DIR="/home/$TARGET_USER"

echo "🛠️ Iniciando a instalação das ferramentas de desenvolvimento para o usuário: $TARGET_USER"

# --- 0. CORREÇÃO DE AMBIENTE E TECLADO ---
echo "--- 0. Configurando teclado e ambiente ---"

# Corrigindo o layout do teclado ThinkPad para persistência no ambiente gráfico
# Este comando deve ser executado como root e redirecionado para o arquivo de inicialização do usuário.
if [ -d "$HOME_DIR" ]; then
    echo "setxkbmap -model thinkpad -layout br" | sudo tee -a /etc/bash.bashrc > /dev/null
    sudo chown $TARGET_USER:$TARGET_USER /etc/bash.bashrc
    
    # Tentativa de persistência para a sessão gráfica do usuário
    sudo mkdir -p $HOME_DIR/Desktop 
    sudo chown -R $TARGET_USER:$TARGET_USER $HOME_DIR
    sudo -u $TARGET_USER mkdir -p $HOME_DIR
    sudo -u $TARGET_USER echo 'setxkbmap -model thinkpad -layout br' >> $HOME_DIR/.xsessionrc
fi

# 1. PREPARAÇÃO GERAL
echo "--- 1. Preparando o sistema (Update e pacotes base) ---"
sudo apt update -y
sudo apt upgrade -y # Executa a atualização completa do sistema
# Instala todos os pacotes essenciais
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common wget gpg lsb-release git -y

# --- 2. INSTALAÇÃO DO DBEAVER CE ---
echo "--- 2. Instalando DBeaver CE ---"
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list > /dev/null
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/dbeaver.gpg > /dev/null
sudo apt update
sudo apt install -y dbeaver-ce

# --- 3. INSTALAÇÃO DO DOCKER & DOCKER COMPOSE ---
echo "--- 3. Instalando Docker e Docker Compose ---"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
VERSION_CODENAME=$(lsb_release -cs)
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo systemctl enable docker
if ! grep -q "docker" /etc/group; then
    sudo groupadd docker
fi
# Adiciona o usuário ao grupo docker
sudo usermod -aG docker "$TARGET_USER"

# --- 4. INSTALAÇÃO DO .NET SDK 6.0 (Executado como o usuário alvo) ---
echo "--- 4. Instalando .NET SDK 6.0 ---"
sudo -u "$TARGET_USER" bash << EOF_DOTNET
    HOME_USER="$HOME_DIR"
    DOTNET_INSTALLER_PATH="$HOME_USER/dotnet-install.sh"
    wget https://dot.net/v1/dotnet-install.sh -O "$DOTNET_INSTALLER_PATH"
    chmod +x "$DOTNET_INSTALLER_PATH"
    "$DOTNET_INSTALLER_PATH" --channel 6.0
    rm "$DOTNET_INSTALLER_PATH"
EOF_DOTNET

# --- 5. INSTALAÇÃO DO NVM (Node Version Manager) e Node.js 18 (Executado como o usuário alvo) ---
echo "--- 5. Instalando NVM e Node.js 18 ---"
sudo -u "$TARGET_USER" bash << EOF_NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME_DIR/.nvm"
    # Carregar NVM (supondo que .bashrc já foi criado)
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    . "$HOME_DIR/.bashrc" 2>/dev/null || . "$HOME_DIR/.zshrc" 2>/dev/null
    
    # Adicionar comandos de carga ao .bashrc do usuário
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME_DIR/.bashrc"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$HOME_DIR/.bashrc"

    if command -v nvm &> /dev/null; then
        nvm install 18
        nvm use 18
    fi
EOF_NVM

# --- 6. INSTALAÇÃO DO POSTMAN ---
echo "--- 6. Instalando Postman ---"
POSTMAN_URL="https://dl.pstmn.io/download/latest/linux64"
POSTMAN_TAR="$HOME_DIR/postman.tar.gz"

sudo wget "$POSTMAN_URL" -O "$POSTMAN_TAR"
sudo tar -xzf "$POSTMAN_TAR" -C /opt
sudo ln -sf /opt/Postman/Postman /usr/bin/postman
sudo rm "$POSTMAN_TAR"

sudo tee /usr/share/applications/postman.desktop > /dev/null << EOF
[Desktop Entry]
Type=Application
Name=Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Exec="/opt/Postman/Postman"
Comment=Postman Desktop App
Categories=Development;Code;
EOF

# --- 7. INSTALAÇÃO DO SLACK ---
echo "--- 7. Instalando Slack ---"
SLACK_URL="https://downloads.slack-edge.com/desktop-releases/linux/x64/4.46.101/slack-desktop-4.46.101-amd64.deb"
SLACK_DEB="$HOME_DIR/slack.deb"

sudo wget "$SLACK_URL" -O "$SLACK_DEB"
sudo apt install "$SLACK_DEB" -y
sudo rm "$SLACK_DEB"

# --- 8. INSTALAÇÃO DO VS CODE E EXTENSÕES ---
echo "--- 8. Instalando VS Code e Extensões ---"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code

echo "Instalando extensões do VS Code..."
EXTENSIONS=(
    ms-dotnettools.vscode-dotnet-runtime
    ms-dotnettools.csharp
    Angular.ng-template
    johnpapa.angular2
    fernandoescolar.vscode-solution-explorer
    esbenp.prettier-vscode
    ms-dotnettools.vscodeintellicode-csharp
    dbaeumer.vscode-eslint
    rangav.vscode-thunder-client
)
# Instala as extensões como o usuário alvo
for EXT in "${EXTENSIONS[@]}"; do
    sudo -u "$TARGET_USER" code --install-extension "$EXT" --force
done

# --- 9. CONFIGURAÇÃO DE WALLPAPER ---
echo "--- 9. Configurando Wallpaper ---"
# Baixa e configura o wallpaper no contexto do usuário
sudo -u "$TARGET_USER" wget -P "$HOME_DIR/Downloads" https://i.ibb.co/cwtDVCS/Frame-6.png
sudo -u "$TARGET_USER" gsettings set org.gnome.desktop.background picture-uri "file://$HOME_DIR/Downloads/Frame-6.png"
sudo -u "$TARGET_USER" gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME_DIR/Downloads/Frame-6.png"
echo "Wallpaper configurado."

# =================================================================
# === 10. REMOÇÃO DE DUPLICATAS (LIMPEZA PÓS-INSTALAÇÃO) ===========
# =================================================================

echo ""
echo "--- 🔟 INICIANDO LIMPEZA DE DUPLICATAS (Removendo versões Snap) ---"

# --- Função de Remoção Snap ---
remove_snap() {
    local app_name=$1
    if command -v snap &> /dev/null && snap list | grep -w "$app_name" &> /dev/null; then
        echo "  -> Removendo SNAP: $app_name (Duplicata)"
        sudo snap remove "$app_name" --purge
    fi
}

# --- Execução da Remoção ---
# Lista de apps que podem ter vindo no ISO base que você não quer duplicados
remove_snap "dbeaver-ce"
remove_snap "postman"
remove_snap "slack"
remove_snap "code"

echo "--- Limpeza de Duplicatas Concluída. ---"

# =================================================================
# === 11. PARTE DE VERIFICAÇÃO AUTOMÁTICA ==========================
# =================================================================

echo ""
echo "--- 🔎 INICIANDO VERIFICAÇÃO DE INSTALAÇÃO DE FERRAMENTAS ---"

FAIL_COUNT=0
SEPARATOR="=================================================="

# Função auxiliar para verificar comandos (simplificada para o script)
verify_command() {
    local command_name="$1"
    echo -n "Verificando $command_name... "
    if command -v "$command_name" &> /dev/null; then
        echo "✅ [OK]"
    else
        echo "❌ [FALHA]"
        return 1
    fi
    return 0
}

# 1. DBeaver CE
echo "$SEPARATOR"
verify_command "dbeaver-ce" || FAIL_COUNT=$((FAIL_COUNT + 1))

# 2. Docker
verify_command "docker" || FAIL_COUNT=$((FAIL_COUNT + 1))

# 3. Docker Compose (Verificando o binário do v1)
verify_command "docker-compose" || FAIL_COUNT=$((FAIL_COUNT + 1))

# 4. VS Code
verify_command "code" || FAIL_COUNT=$((FAIL_COUNT + 1))

# 5. Slack (Verificar existência do binário do .deb)
verify_command "slack" || FAIL_COUNT=$((FAIL_COUNT + 1))

# 6. Postman (Verificar existência do binário do link simbólico)
if [ -L "/usr/bin/postman" ]; then
    echo -n "Verificando Postman... "
    echo "✅ [OK]"
else
    echo -n "Verificando Postman... "
    echo "❌ [FALHA]"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# 7. NVM (Verificação de script no home)
if [ -f "$HOME_DIR/.nvm/nvm.sh" ]; then
    echo -n "Verificando NVM... "
    echo "✅ [OK]"
else
    echo -n "Verificando NVM... "
    echo "❌ [FALHA]"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Resumo Final
echo "$SEPARATOR"
if [ $FAIL_COUNT -eq 0 ]; then
    echo "🎉 RESULTADO FINAL: Todas as verificações de comandos básicos foram bem-sucedidas."
else
    echo "⚠️ RESULTADO FINAL: $FAIL_COUNT falha(s) detectada(s). Verifique os programas com ❌."
fi
echo "=================================================="

echo "⚠️ RECOMENDAÇÃO: Faça logout e login novamente para ativar as permissões do Docker e o NVM."
