RODAR COMANDO PARA INSTALAR E VERIFICAR SUCESSOS: 

sudo apt update && sudo apt install -y curl wget || true && \
(curl -fsSL https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install_funcionando.sh 2>/dev/null || wget -O - https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install_funcionando.sh 2>/dev/null) | bash


DBeaver:

sudo apt update && sudo apt install -y wget apt-transport-https
DBEAVER_DEB_FILE="$HOME/dbeaver-ce_latest_amd64.deb" && \
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O "$DBEAVER_DEB_FILE" && \
sudo dpkg -i "$DBEAVER_DEB_FILE" && \
sudo apt install -f -y && \
rm "$DBEAVER_DEB_FILE" && \
echo "✅ DBeaver CE instalado com sucesso."

Reomver Programas repetidos:
curl -s "https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/programas_repetidos.sh" | bash
