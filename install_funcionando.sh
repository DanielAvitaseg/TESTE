#!/bin/bash

# Este script instala o Docker Compose v2 (como plugin do Docker CLI) e o NVM no Linux.

# Versão atual do Docker Compose no momento da criação do script (Verifique a última em https://github.com/docker/compose/releases)
DOCKER_COMPOSE_VERSION="v2.40.2"

echo "🚀 Iniciando a instalação das ferramentas..."

# --- Instalação do Docker Compose v2 ---
echo "⚙️ Instalando o Docker Compose ($DOCKER_COMPOSE_VERSION)..."

# 1. Define o diretório de plugins do Docker.
DOCKER_CLI_PLUGINS_DIR="$HOME/.docker/cli-plugins"
mkdir -p $DOCKER_CLI_PLUGINS_DIR

# 2. Baixa o binário do Docker Compose v2 para a arquitetura do sistema e renomeia para 'docker-compose'.
# Usa 'uname -s' para o SO (Linux) e 'uname -m' para a arquitetura (ex: x86_64, aarch64).
curl -SL https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m) -o $DOCKER_CLI_PLUGINS_DIR/docker-compose

# 3. Dá permissão de execução ao binário.
chmod +x $DOCKER_CLI_PLUGINS_DIR/docker-compose

# 4. Verifica a instalação
if command -v docker > /dev/null && docker compose version > /dev/null 2>&1; then
    echo "✅ Docker Compose instalado com sucesso como plugin do Docker CLI."
    docker compose version
else
    echo "⚠️ ATENÇÃO: O Docker Compose foi instalado, mas você precisará do Docker Engine instalado para usá-lo."
    echo "Para usar: docker compose [comando]"
fi

echo "------------------------------------"

# --- Instalação do NVM (Node Version Manager) ---
echo "⚙️ Instalando o NVM..."

# Baixa e executa o script de instalação do NVM.
# A versão mais recente é obtida diretamente do repositório oficial.
# O script adiciona as linhas necessárias para carregar o NVM no seu arquivo de perfil (~/.bashrc, ~/.zshrc, etc.)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# 1. Tenta carregar o NVM na sessão atual (depende do shell)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# 2. Verifica a instalação do NVM
if command -v nvm > /dev/null; then
    echo "✅ NVM instalado com sucesso."
    nvm --version
    echo "Instale uma versão do Node.js, por exemplo: nvm install node"
else
    echo "⚠️ NVM instalado, mas a configuração do shell precisa ser carregada."
fi

echo "------------------------------------"
echo "🎉 Instalação concluída."
echo "Para usar o NVM na sua sessão atual, feche e reabra o terminal ou execute:"
echo "source ~/.bashrc  (ou ~/.zshrc, dependendo do seu shell)"
echo "------------------------------------"
