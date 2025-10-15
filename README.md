RODAR COMANDO PARA INSTALAR E VERIFICAR SUCESSOS: 

sudo apt update && sudo apt install -y curl wget || true && \
(curl -fsSL https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null || wget -O - https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null) | bash


DBeaver:

# 1. Atualiza a lista de pacotes e instala 'wget' (para baixar) e 'apt-transport-https' (se não estiverem presentes)
sudo apt update && sudo apt install -y wget apt-transport-https

# 2. Define o nome do arquivo .deb
DBEAVER_DEB_FILE="$HOME/dbeaver-ce_latest_amd64.deb"

# 3. Baixa a última versão do pacote .deb do site oficial
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O "$DBEAVER_DEB_FILE"

# 4. Instala o pacote .deb
sudo dpkg -i "$DBEAVER_DEB_FILE"

# 5. Instala quaisquer dependências que o DBeaver possa exigir (corrige erros do dpkg)
sudo apt install -f -y

# 6. Limpa o arquivo .deb baixado
rm "$DBEAVER_DEB_FILE"

echo "✅ DBeaver CE instalado com sucesso."
