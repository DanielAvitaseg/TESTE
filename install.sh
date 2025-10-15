#cloud-config
autoinstall:
  version: 1
  
  # ====================================================================
  # CONFIGURAÇÃO DE ARMAZENAMENTO (LVM sobre LUKS no /dev/nvme0n1)
  # ====================================================================
  storage:
    wipe: all
    layout:
      name: lvm
      match: 
        path: /dev/nvme0n1
      
      # SENHA DE CRIPTOGRAFIA (LUKS)
      password: Senhafoda123@ 

  # ====================================================================
  # CONFIGURAÇÕES DE SISTEMA E USUÁRIO
  # ====================================================================
  identity:
    hostname: notebook-ubuntu
    username: testuser
    # Hash SHA-512 da senha
    password: "$6$EAyehhfqepzaGX78$k4Qceki0nxJKS2.ZxcWyWjn7db3p7/0Qu.S6pr32pIqVpzfFmwnOj/.XKgY6x3ADG077lE.DoNwMpXZ2aXr3q." 
    
    # CORREÇÃO CRUCIAL: Força a habilitação do login por senha (SSH)
    # Isso garante que a senha acima funcione após o boot.
    ssh_pwauth: true
    
  locale: pt_BR
  timezone: America/Sao_Paulo
  
  keyboard:
    layout: br
    # A variante 'abnt2' foi removida, pois 'br' é suficiente.
    
  # Instala o servidor SSH para poder gerenciar remotamente
  ssh:
    install-server: true

  # ====================================================================
  # PÓS-INSTALAÇÃO E EXECUÇÃO DE SCRIPTS
  # ====================================================================
  late-commands:
    # 1. Atualização do sistema recém-instalado
    - curtin in-target -- apt update
    - curtin in-target -- apt upgrade -y
    
    # 2. INSTALAÇÃO DE PROGRAMAS VIA SCRIPT REMOTO E DBEAVER
    - |
      curtin in-target -- bash -c <<'EOF'
        
        # O sistema de destino precisa de curl e wget para os downloads
        sudo apt update && sudo apt install -y curl wget || true
        
        echo "Executando script remoto install.sh..."
        
        # Baixa e executa o script remoto
        (curl -fsSL https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null || \
         wget -O - https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null) | bash
        
        echo "✅ Script remoto executado com sucesso."

        # ==========================================================
        # Instalação do DBeaver CE
        # ==========================================================
        DBEAVER_DEB_FILE="/tmp/dbeaver-ce_latest_amd64.deb"

        echo "Iniciando instalação do DBeaver..."

        # Instala dependências e baixa o pacote .deb
        sudo apt install -y apt-transport-https 
        wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O "$DBEAVER_DEB_FILE" 

        # Instala e resolve dependências (crucial para pacotes .deb)
        sudo dpkg -i "$DBEAVER_DEB_FILE" 
        sudo apt install -f -y 

        # Limpeza
        rm "$DBEAVER_DEB_FILE" 
        
        echo "✅ DBeaver CE instalado com sucesso."

EOF
  # 3. Ação final (Reinicialização)
  power-state:
    delay: 5
    mode: reboot
