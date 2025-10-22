#!/bin/bash
# Script de Instalação Unificado e Auto-Verificação para Ferramentas de Desenvolvimento (Debian/Ubuntu)

echo "🛠️ Iniciando a instalação das ferramentas de desenvolvimento..."

# --- 1. PREPARAÇÃO GERAL (CURL GARANTIDO) ---
echo "--- 1. Preparando o sistema (Update e pacotes base, incluindo curl) ---"
sudo apt update -y
# Instala todos os pacotes essenciais, incluindo curl, wget e gpg.
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common wget gpg lsb-release

# --- 2. INSTALAÇÃO DO DBEAVER CE ---
echo "--- 2. Instalando DBeaver CE ---"
DOCKER_DESKTOP_TARGET="/usr/share/applications/dbeaver-ce.desktop"

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
sudo usermod -aG docker "$USER"

# --- 4. INSTALAÇÃO DO .NET SDK 6.0 ---
echo "--- 4. Instalando .NET SDK 6.0 ---"
DOTNET_INSTALLER_PATH="$HOME/dotnet-install.sh"
wget https://dot.net/v1/dotnet-install.sh -O "$DOTNET_INSTALLER_PATH"
chmod +x "$DOTNET_INSTALLER_PATH"
"$DOTNET_INSTALLER_PATH" --channel 6.0
rm "$DOTNET_INSTALLER_PATH"

# --- 5. INSTALAÇÃO DO NVM (Node Version Manager) e Node.js 18 ---
echo "--- 5. Instalando NVM e Node.js 18 ---"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

. "$HOME/.bashrc" 2>/dev/null || . "$HOME/.zshrc" 2>/dev/null
if command -v nvm &> /dev/null; then
    nvm install 18
    nvm use 18
fi

# --- 6. INSTALAÇÃO DO POSTMAN ---
echo "--- 6. Instalando Postman ---"
POSTMAN_URL="https://dl.pstmn.io/download/latest/linux64"
POSTMAN_TAR="$HOME/postman.tar.gz"

wget "$POSTMAN_URL" -O "$POSTMAN_TAR"
sudo tar -xzf "$POSTMAN_TAR" -C /opt
sudo ln -sf /opt/Postman/Postman /usr/bin/postman
rm "$POSTMAN_TAR"

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
SLACK_DEB="$HOME/slack.deb"

wget "$SLACK_URL" -O "$SLACK_DEB"
sudo apt install "$SLACK_DEB" -y
rm "$SLACK_DEB"

# --- 8. INSTALAÇÃO DO VS CODE E EXTENSÕES ---
echo "--- 8. Instalando VS Code e Extensões ---"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
rm microsoft.gpg
sudo apt update
sudo apt install -y code

echo "Instalando extensões do VS Code..."
if command -v code &> /dev/null; then
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
    for EXT in "${EXTENSIONS[@]}"; do
        code --install-extension "$EXT" --force
    done
fi

# --- 9. CONFIGURAÇÃO DE WALLPAPER ---
echo "--- 9. Configurando Wallpaper ---"
# O comando usa gsettings, que geralmente funciona melhor quando executado no contexto do usuário
# ou por um usuário que terá uma sessão gráfica.
# Se o script for executado como root, o gsettings pode não funcionar corretamente.
# No entanto, mantemos a lógica do usuário:
wget -P "$HOME/Downloads" https://i.ibb.co/cwtDVCS/Frame-6.png
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Downloads/Frame-6.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Downloads/Frame-6.png"
echo "Wallpaper configurado."


# =================================================================
# === PARTE DE VERIFICAÇÃO AUTOMÁTICA ===============================
# =================================================================

echo ""
echo "--- 🔎 INICIANDO VERIFICAÇÃO DE INSTALAÇÃO DE FERRAMENTAS ---"

FAIL_COUNT=0
SEPARATOR="=================================================="

# Função auxiliar para verificar comandos
verify_command() {
    local command_name="$1"
    local verification_command="$2"
    local expected_output_regex="$3"

    echo -n "Verificando $command_name... "
    if command -v "$command_name" &> /dev/null; then
        output=$($verification_command 2>&1)
        if [[ $output =~ $expected_output_regex ]]; then
            echo "✅ [OK] (Versão: $(echo "$output" | head -n 1 | awk '{print $NF}'))"
        else
            echo "⚠️ [AVISO] Comando encontrado, mas a versão/saída não é clara."
        fi
    else
        echo "❌ [FALHA] Comando não encontrado."
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# 1. DBeaver CE (Verificar existência do arquivo desktop)
echo "$SEPARATOR"
DOCKER_DESKTOP_VERIFY="/usr/share/applications/dbeaver-ce.desktop"
echo -n "Verificando DBeaver CE... "
if [ -f "$DOCKER_DESKTOP_VERIFY" ]; then
    echo "✅ [OK] (Atalho .desktop encontrado)"
else
    if [ -x "/usr/bin/dbeaver-ce" ]; then
        echo "⚠️ [AVISO] Atalho não encontrado, mas executável DBeaver existe em /usr/bin/."
    else
        echo "❌ [FALHA] (Atalho ou Executável não encontrado.)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
fi

# 2. Docker
echo "$SEPARATOR"
verify_command "docker" "docker --version" "Docker version"

# 3. Docker Compose (Verificando o binário do v1)
verify_command "docker-compose" "docker-compose --version" "docker-compose version"

# 4. .NET SDK 6.0 (Apenas no diretório do usuário)
echo "$SEPARATOR"
DOTNET_PATH="$HOME/.dotnet/dotnet"
echo -n "Verificando .NET SDK 6.0 (local)... "
if [ -x "$DOTNET_PATH" ]; then
    VERSION_OUTPUT=$("$DOTNET_PATH" --version 2>&1 | grep -E '^(6\.|7\.|8\.)')
    if [ -n "$VERSION_OUTPUT" ]; then
        echo "✅ [OK] (Versão: $VERSION_OUTPUT)"
    else
        echo "❌ [FALHA] Executável .NET encontrado, mas a versão 6.0+ não foi detectada."
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "❌ [FALHA] Executável .NET não encontrado em $DOTNET_PATH."
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# 5. NVM e Node.js 18
echo "$SEPARATOR"
NVM_DIR_CHECK="$HOME/.nvm/nvm.sh"
echo -n "Verificando NVM... "
if [ -f "$NVM_DIR_CHECK" ]; then
    echo "✅ [OK] (Script nvm.sh encontrado)"
    
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    echo -n "Verificando Node.js 18... "
    if command -v node &> /dev/null && [[ $(node -v 2>&1) =~ v18 ]]; then
        echo "✅ [OK] (Versão: $(node -v 2>&1))"
    else
        echo "⚠️ [AVISO] Node (ou Node 18) pode não estar carregado. Use 'nvm use 18' em um novo terminal."
    fi
else
    echo "❌ [FALHA] NVM não encontrado."
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi


# 6. Postman
echo "$SEPARATOR"
POSTMAN_LINK="/usr/bin/postman"
POSTMAN_DESKTOP_VERIFY="/usr/share/applications/postman.desktop"
echo -n "Verificando Postman... "
if [ -L "$POSTMAN_LINK" ] && [ -f "$POSTMAN_DESKTOP_VERIFY" ]; then
    echo "✅ [OK] (Link e Atalho .desktop encontrados)"
else
    echo "❌ [FALHA] Link ou Atalho .desktop não encontrado."
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# 7. Slack
echo "$SEPARATOR"
verify_command "slack" "slack --version" "."

# 8. VS Code
echo "$SEPARATOR"
verify_command "code" "code --version" ".*"

# Resumo Final
echo "$SEPARATOR"
if [ $FAIL_COUNT -eq 0 ]; then
    echo "🎉 RESULTADO FINAL: Todas as verificações de comandos básicos foram bem-sucedidas."
else
    echo "⚠️ RESULTADO FINAL: $FAIL_COUNT falha(s) detectada(s). Verifique os programas com ❌."
fi
echo "=================================================="

echo "⚠️ RECOMENDAÇÃO: Faça logout e login novamente para ativar as permissões do Docker e o NVM."
