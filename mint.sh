#!/bin/bash

# Define a função de tratamento de erro
function error_check {
    if [ $? -ne 0 ]; then
        echo -e "\n🚨 ERRO: Falha na última execução. Saindo do script."
        exit 1
    fi
}

echo "=================================================="
echo "      🚀 Iniciando Configuração do Ambiente 🚀     "
echo "=================================================="

# Variáveis
# O codinome correto é 'noble' (Ubuntu 24.04).
# Usamos 'jammy' como fallback para repositórios que não suportam 'noble' ainda.
UBUNTU_CODENAME_FALLBACK="jammy"
UBUNTU_CODENAME_CURRENT=$(lsb_release -cs)

# --- [1/5] Atualizando e instalando dependências essenciais ---
echo -e "\n--- [1/5] Atualizando e instalando dependências essenciais ---"
apt update
error_check
apt upgrade -y
error_check
apt install -y wget gpg apt-transport-https ca-certificates curl software-properties-common
error_check

# --- [2/5] Configurando Repositórios (Microsoft e DBeaver) ---
echo -e "\n--- [2/5] Configurando Repositórios (Microsoft e DBeaver) ---"

# 2.1 Repositório da Microsoft (Ex: VS Code)
echo "Adicionando Repositório da Microsoft..."
# A linha que falhou no seu log está aqui. Forçamos o fallback para 'jammy'.
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
error_check
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable ${UBUNTU_CODENAME_FALLBACK}" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
error_check

# 2.2 Repositório DBeaver
echo "Adicionando Repositório DBeaver..."
curl -fsSL https://dbeaver.io/debs/dbeaver.gpg | gpg --dearmor -o /usr/share/keyrings/dbeaver.gpg
error_check
echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce/ /" | tee /etc/apt/sources.list.d/dbeaver.list > /dev/null
error_check

# Atualiza novamente a lista de pacotes para incluir os novos repositórios
echo "Atualizando lista de pacotes..."
apt update
error_check


# --- [3/5] Instalando Docker Engine ---
echo -e "\n--- [3/5] Instalando Docker Engine ---"

# Desinstala versões antigas para garantir
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt remove $pkg -y > /dev/null 2>&1; done

# Adiciona a chave GPG do Docker
echo "Adicionando chave GPG do Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
error_check

# Adiciona o repositório do Docker
echo "Configurando Repositório do Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $UBUNTU_CODENAME_CURRENT stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
error_check

# Instala Docker e dependências
apt update
error_check
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
error_check


# --- [4/5] Instalando Softwares (VS Code e DBeaver) ---
echo -e "\n--- [4/5] Instalando VS Code e DBeaver ---"
apt install -y code dbeaver-ce
error_check


# --- [5/5] Pós-Instalação e Verificação ---
echo -e "\n--- [5/5] Pós-Instalação e Verificação ---"

# Adiciona o usuário 'ubuntu' ao grupo docker (útil se você sair do root)
if id -u ubuntu >/dev/null 2>&1; then
    echo "Adicionando usuário 'ubuntu' ao grupo docker..."
    usermod -aG docker ubuntu
fi

# Verifica as versões instaladas
echo "Versão do Docker:"
docker --version
echo "Verificação do VS Code: (deve ser '0')"
dpkg -l | grep code | grep "ii" | wc -l
echo "Verificação do DBeaver: (deve ser '1')"
dpkg -l | grep dbeaver-ce | grep "ii" | wc -l

echo "=================================================="
echo "✅ Configuração concluída com sucesso! ✅"
echo "=================================================="
