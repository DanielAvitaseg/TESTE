RODAR COMANDO PARA INSTALAR E VERIFICAR SUCESSOS: 

sudo apt update && sudo apt install -y curl wget || true && \
(curl -fsSL https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install_funcionando.sh 2>/dev/null || wget -O - https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install_funcionando.sh 2>/dev/null) | bash


wget -O ~/Imagens/novo-wallpaper.png https://i.ibb.co/pjFjN4hS/Novos-colaboradores-2-2.png && gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/Imagens/novo-wallpaper.png" && gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$USER/Imagens/novo-wallpaper.png"
