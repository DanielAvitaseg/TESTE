#!/bin/bash
# Script de Instalação Unificado para Ferramentas de Desenvolvimento (Debian/Ubuntu)
#
# Programas Incluídos:
# 1. DBeaver CE
# 2. Docker & Docker Compose
# 3. .NET SDK 6.0 (Instalado apenas localmente - $HOME/.dotnet)
# 4. NVM (Node Version Manager) e Node.js 18
# 5. Postman
# 6. Slack
# 7. VS Code (com extensões específicas)

echo "🛠️ Iniciando a instalação das ferramentas de desenvolvimento..."

# --- 1. PREPARAÇÃO GERAL ---
echo "--- 1. Preparando o sistema (Update e pacotes base) ---"
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common wget gpg

---

# --- 2. INSTALAÇÃO DO DBEAVER CE ---
echo "--- 2. Instalando DBeaver CE ---"
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/dbeaver.gpg > /dev/null
sudo apt update
sudo apt install -y dbeaver-ce

---

# --- 3. INSTALAÇÃO DO DOCKER & DOCKER COMPOSE ---
echo "--- 3. Instalando Docker e Docker Compose ---"
# Adiciona a chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Adiciona o repositório do Docker (Referência ao focal/Ubuntu 20.04 - Ajuste se precisar de outra versão)
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
# Configura permissões para o usuário atual
if ! grep -q "docker" /etc/group; then
    sudo groupadd docker
fi
sudo usermod -aG docker "$USER"
echo "⚠️ OBS: Você precisará fazer logout e login novamente para que as permissões do Docker entrem em vigor."
# Instala Docker Compose
DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

---

# --- 4. INSTALAÇÃO DO .NET SDK 6.0 ---
echo "--- 4. Instalando .NET SDK 6.0 ---"
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh --channel 6.0
rm dotnet-install.sh
echo ".NET SDK 6.0 instalado em $HOME/.dotnet. Para usá-lo globalmente, adicione $HOME/.dotnet à sua variável PATH."

---

# --- 5. INSTALAÇÃO DO NVM (Node Version Manager) e Node.js 18 ---
echo "--- 5. Instalando NVM e Node.js 18 ---"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash # Versão mais recente
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Carrega nvm
# Tenta carregar as novas variáveis no ambiente atual (Pode falhar em alguns shells)
. "$HOME/.bashrc" 2>/dev/null || . "$HOME/.zshrc" 2>/dev/null || echo "Aviso: Não foi possível recarregar o shell. Você precisará iniciar um novo terminal para usar 'nvm'."
# Instala e usa Node 18
if command -v nvm &> /dev/null; then
    nvm install 18
    nvm use 18
else
    echo "NVM não foi carregado corretamente. Por favor, abra um novo terminal e execute 'nvm install 18 && nvm use 18'."
fi

---

# --- 6. INSTALAÇÃO DO POSTMAN ---
echo "--- 6. Instalando Postman ---"
POSTMAN_URL=$(curl -s https://www.postman.com/downloads/ | grep -oP 'https://dl.pstmn.io/download/latest/linux64\?.*' | head -1) # Tenta pegar o link mais recente
if [ -z "$POSTMAN_URL" ]; then
    echo "Aviso: Não foi possível obter o link mais recente. Usando link fixo (Pode estar desatualizado)."
    POSTMAN_URL="https://dl.pstmn.io/download/latest/linux64"
fi
wget "$POSTMAN_URL" -O postman.tar.gz
sudo tar -xzf postman.tar.gz -C /opt
sudo ln -sf /opt/Postman/Postman /usr/bin/postman # Usa -sf para forçar o link simbólico
rm postman.tar.gz
# Cria atalho no menu
sudo tee /usr/share/applications/postman.desktop > /dev/null << EOF
[Desktop Entry]
Type=Application
Name=Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Exec="/opt/Postman/Postman"
Comment=Postman Desktop App
Categories=Development;Code;
EOF

---

# --- 7. INSTALAÇÃO DO SLACK ---
echo "--- 7. Instalando Slack ---"
# Tenta obter o link mais recente diretamente da página de download
SLACK_URL=$(curl -s https://slack.com/intl/pt-br/downloads/linux | grep -oP 'https://downloads.slack-edge.com/releases/linux/.*\.deb' | head -1)
if [ -z "$SLACK_URL" ]; then
    echo "Aviso: Não foi possível obter o link mais recente. Usando link fixo (Pode estar desatualizado)."
    SLACK_URL="https://downloads.slack-edge.com/releases/linux/4.33.84/prod/x64/slack-desktop-4.33.84-amd64.deb"
fi
wget "$SLACK_URL" -O slack.deb
sudo dpkg -i slack.deb
sudo apt --fix-broken install -y # Garante que dependências sejam instaladas
rm slack.deb

---

# --- 8. INSTALAÇÃO DO VS CODE E EXTENSÕES ---
echo "--- 8. Instalando VS Code e Extensões ---"
# Adiciona chave e repositório do VS Code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
rm microsoft.gpg
sudo apt update
sudo apt install -y code

# Instala extensões do VS Code
echo "Instalando extensões do VS Code..."
if command -v code &> /dev/null; then
    # Lista de extensões
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
        echo "Instalando $EXT..."
        code --install-extension "$EXT" --force # Adicionei --force para evitar problemas
    done
else
    echo "Aviso: O comando 'code' não foi encontrado. Extensões do VS Code não instaladas."
fi

# --- FIM ---
echo ""
echo "✅ Instalação concluída!"
echo "⚠️ Lembre-se de sair e entrar novamente (ou 'newgrp docker' em um novo shell) para que as permissões do Docker funcionem."
echo "⚠️ O NVM e o Node.js 18 devem estar disponíveis em um novo terminal."
