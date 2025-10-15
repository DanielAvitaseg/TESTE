RODAR COMANDO PARA INSTALAR E VERIFICAR SUCESSOS: 

sudo apt update && sudo apt install -y curl wget || true && \
(curl -fsSL https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null || wget -O - https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null) | bash
