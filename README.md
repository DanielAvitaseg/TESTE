RODAR COMANDO PARA INSTALAR E VERIFICAR SUCESSOS: 

sudo apt update && sudo apt install -y curl wget || true && \
(curl -fsSL https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null || wget -O - https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null) | bash


DBeaver:

# 1. Atualiza e instala wget (e outros pacotes de dependência que podem ser úteis)
sudo apt update && sudo apt install -y wget apt-transport-https

# 2. Define a variável, baixa, instala o .deb e limpa, TUDO SEPARADO
DBEAVER_DEB_FILE="$HOME/dbeaver-ce_latest_amd64.deb" && \
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O "$DBEAVER_DEB_FILE" && \
sudo dpkg -i "$DBEAVER_DEB_FILE" && \
sudo apt install -f -y && \
rm "$DBEAVER_DEB_FILE" && \
echo "✅ DBeaver CE instalado com sucesso."
