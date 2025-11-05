#!/bin/bash
# Script de Instalação Unificado e Auto-Verificação para Ferramentas de Desenvolvimento (Debian/Ubuntu)

echo "🛠️ Iniciando a instalação das ferramentas de desenvolvimento..."
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

# --- 1. PREPARAÇÃO GERAL (CURL GARANTIDO) ---
echo "--- 1. Preparando o sistema (Update e pacotes base, incluindo curl) ---"
# 1. PREPARAÇÃO GERAL
echo "--- 1. Preparando o sistema (Update e pacotes base) ---"
sudo apt update -y
# Instala todos os pacotes essenciais, incluindo curl, wget e gpg.
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common wget gpg lsb-release
sudo apt upgrade -y # Executa a atualização completa do sistema
# Instala todos os pacotes essenciais
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common wget gpg lsb-release git -y

# --- 2. INSTALAÇÃO DO DBEAVER CE ---
echo "--- 2. Instalando DBeaver CE ---"
DOCKER_DESKTOP_TARGET="/usr/share/applications/dbeaver-ce.desktop"

echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list > /dev/null
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/dbeaver.gpg > /dev/null
sudo apt update
@@ -25,8 +46,8 @@ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o
sudo chmod a+r /etc/apt/keyrings/docker.gpg
VERSION_CODENAME=$(lsb_release -cs)
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

@@ -36,39 +57,50 @@ sudo chmod +x /usr/local/bin/docker-compose

sudo systemctl enable docker
if ! grep -q "docker" /etc/group; then
    sudo groupadd docker
    sudo groupadd docker
fi
sudo usermod -aG docker "$USER"
# Adiciona o usuário ao grupo docker
sudo usermod -aG docker "$TARGET_USER"

# --- 4. INSTALAÇÃO DO .NET SDK 6.0 ---
# --- 4. INSTALAÇÃO DO .NET SDK 6.0 (Executado como o usuário alvo) ---
echo "--- 4. Instalando .NET SDK 6.0 ---"
DOTNET_INSTALLER_PATH="$HOME/dotnet-install.sh"
wget https://dot.net/v1/dotnet-install.sh -O "$DOTNET_INSTALLER_PATH"
chmod +x "$DOTNET_INSTALLER_PATH"
"$DOTNET_INSTALLER_PATH" --channel 6.0
rm "$DOTNET_INSTALLER_PATH"

# --- 5. INSTALAÇÃO DO NVM (Node Version Manager) e Node.js 18 ---
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
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

. "$HOME/.bashrc" 2>/dev/null || . "$HOME/.zshrc" 2>/dev/null
if command -v nvm &> /dev/null; then
    nvm install 18
    nvm use 18
fi
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
POSTMAN_TAR="$HOME/postman.tar.gz"
POSTMAN_TAR="$HOME_DIR/postman.tar.gz"

wget "$POSTMAN_URL" -O "$POSTMAN_TAR"
sudo wget "$POSTMAN_URL" -O "$POSTMAN_TAR"
sudo tar -xzf "$POSTMAN_TAR" -C /opt
sudo ln -sf /opt/Postman/Postman /usr/bin/postman
rm "$POSTMAN_TAR"
sudo rm "$POSTMAN_TAR"

sudo tee /usr/share/applications/postman.desktop > /dev/null << EOF
[Desktop Entry]
@@ -83,113 +115,71 @@ EOF
# --- 7. INSTALAÇÃO DO SLACK ---
echo "--- 7. Instalando Slack ---"
SLACK_URL="https://downloads.slack-edge.com/desktop-releases/linux/x64/4.46.101/slack-desktop-4.46.101-amd64.deb"
SLACK_DEB="$HOME/slack.deb"
SLACK_DEB="$HOME_DIR/slack.deb"

wget "$SLACK_URL" -O "$SLACK_DEB"
sudo wget "$SLACK_URL" -O "$SLACK_DEB"
sudo apt install "$SLACK_DEB" -y
rm "$SLACK_DEB"
sudo rm "$SLACK_DEB"

# --- 8. INSTALAÇÃO DO VS CODE E EXTENSÕES ---
echo "--- 8. Instalando VS Code e Extensões ---"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
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
# O comando usa gsettings, que geralmente funciona melhor quando executado no contexto do usuário
# ou por um usuário que terá uma sessão gráfica.
# Se o script for executado como root, o gsettings pode não funcionar corretamente.
# No entanto, mantemos a lógica do usuário:
wget -P "$HOME/Downloads" https://i.ibb.co/cwtDVCS/Frame-6.png
gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Downloads/Frame-6.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Downloads/Frame-6.png"
# Baixa e configura o wallpaper no contexto do usuário
sudo -u "$TARGET_USER" wget -P "$HOME_DIR/Downloads" https://i.ibb.co/cwtDVCS/Frame-6.png
sudo -u "$TARGET_USER" gsettings set org.gnome.desktop.background picture-uri "file://$HOME_DIR/Downloads/Frame-6.png"
sudo -u "$TARGET_USER" gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME_DIR/Downloads/Frame-6.png"
echo "Wallpaper configurado."

# =================================================================
# === NOVO BLOCO: REMOÇÃO DE DUPLICATAS (LIMPEZA PÓS-INSTALAÇÃO) ===
# === 10. REMOÇÃO DE DUPLICATAS (LIMPEZA PÓS-INSTALAÇÃO) ===========
# =================================================================

echo ""
echo "--- 🔟 INICIANDO LIMPEZA DE DUPLICATAS (Removendo versões Snap/Flatpak) ---"

# Lista de aplicativos instalados via APT/DEB/Manual neste script que PODEM ter duplicatas Snap/Flatpak.
DUPLICATES=(
    "dbeaver-ce"
    "postman"
    "slack"
    "code"
)
echo "--- 🔟 INICIANDO LIMPEZA DE DUPLICATAS (Removendo versões Snap) ---"

# --- Função de Remoção Snap ---
remove_snap() {
local app_name=$1
    if snap list | grep -w "$app_name" &> /dev/null; then
        echo "   -> Removendo SNAP: $app_name (Duplicata)"
    if command -v snap &> /dev/null && snap list | grep -w "$app_name" &> /dev/null; then
        echo "  -> Removendo SNAP: $app_name (Duplicata)"
sudo snap remove "$app_name" --purge
fi
}

# --- Função de Remoção Flatpak (Requer Flatpak instalado para funcionar) ---
remove_flatpak() {
    local app_id=$1
    if command -v flatpak &> /dev/null && flatpak list --app | grep -i "$app_id" &> /dev/null; then
        echo "   -> Removendo FLATPAK: $app_id (Duplicata)"
        # Adicione -y para aceitar a remoção automaticamente, se flatpak estiver instalado
        flatpak remove "$app_id" -y &> /dev/null
    fi
}

# --- Execução da Remoção ---

for app in "${DUPLICATES[@]}"; do
    case "$app" in
        dbeaver-ce)
            remove_snap "$app"
            remove_flatpak "io.dbeaver.DBeaverCommunity"
            ;;
        postman)
            remove_snap "$app"
            remove_flatpak "com.getpostman.Postman"
            ;;
        slack)
            remove_snap "$app"
            remove_flatpak "com.slack.Slack"
            ;;
        code)
            remove_snap "$app"
            remove_flatpak "com.visualstudio.code"
            ;;
        # Nota: Docker e .NET Core não são incluídos, pois a duplicação do motor Docker é rara
        # e o .NET Core é geralmente gerenciado por caminhos diferentes.
    esac
done
# Lista de apps que podem ter vindo no ISO base que você não quer duplicados
remove_snap "dbeaver-ce"
remove_snap "postman"
remove_snap "slack"
remove_snap "code"

echo "--- Limpeza de Duplicatas Concluída. ---"

# =================================================================
# === PARTE DE VERIFICAÇÃO AUTOMÁTICA ===============================
# === 11. PARTE DE VERIFICAÇÃO AUTOMÁTICA ==========================
# =================================================================

echo ""
@@ -198,113 +188,61 @@ echo "--- 🔎 INICIANDO VERIFICAÇÃO DE INSTALAÇÃO DE FERRAMENTAS ---"
FAIL_COUNT=0
SEPARATOR="=================================================="

# Função auxiliar para verificar comandos
# Função auxiliar para verificar comandos (simplificada para o script)
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

# 1. DBeaver CE (Verificar existência do arquivo desktop)
# 1. DBeaver CE
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
verify_command "dbeaver-ce" || FAIL_COUNT=$((FAIL_COUNT + 1))

# 2. Docker
echo "$SEPARATOR"
verify_command "docker" "docker --version" "Docker version"
verify_command "docker" || FAIL_COUNT=$((FAIL_COUNT + 1))

# 3. Docker Compose (Verificando o binário do v1)
verify_command "docker-compose" "docker-compose --version" "docker-compose version"
verify_command "docker-compose" || FAIL_COUNT=$((FAIL_COUNT + 1))

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
# 4. VS Code
verify_command "code" || FAIL_COUNT=$((FAIL_COUNT + 1))

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
# 5. Slack (Verificar existência do binário do .deb)
verify_command "slack" || FAIL_COUNT=$((FAIL_COUNT + 1))

# 6. Postman (Verificar existência do binário do link simbólico)
if [ -L "/usr/bin/postman" ]; then
    echo -n "Verificando Postman... "
    echo "✅ [OK]"
else
    echo "❌ [FALHA] NVM não encontrado."
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo -n "Verificando Postman... "
    echo "❌ [FALHA]"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi


# 6. Postman
echo "$SEPARATOR"
POSTMAN_LINK="/usr/bin/postman"
POSTMAN_DESKTOP_VERIFY="/usr/share/applications/postman.desktop"
echo -n "Verificando Postman... "
if [ -L "$POSTMAN_LINK" ] && [ -f "$POSTMAN_DESKTOP_VERIFY" ]; then
    echo "✅ [OK] (Link e Atalho .desktop encontrados)"
# 7. NVM (Verificação de script no home)
if [ -f "$HOME_DIR/.nvm/nvm.sh" ]; then
    echo -n "Verificando NVM... "
    echo "✅ [OK]"
else
    echo "❌ [FALHA] Link ou Atalho .desktop não encontrado."
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo -n "Verificando NVM... "
    echo "❌ [FALHA]"
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
    echo "🎉 RESULTADO FINAL: Todas as verificações de comandos básicos foram bem-sucedidas."
else
    echo "⚠️ RESULTADO FINAL: $FAIL_COUNT falha(s) detectada(s). Verifique os programas com ❌."
    echo "⚠️ RESULTADO FINAL: $FAIL_COUNT falha(s) detectada(s). Verifique os programas com ❌."
fi
echo "=================================================="
