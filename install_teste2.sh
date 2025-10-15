#cloud-config
autoinstall:
  version: 1
  
  # ====================================================================
  # CONFIGURAÇÃO DE ARMAZENAMENTO (LVM sobre LUKS no /dev/nvme0n1)
  # Usa o layout 'lvm' padrao para criptografia de disco completo (FDE).
  # ====================================================================
  storage:
    # Garante a limpeza total do disco antes de particionar
    wipe: all
    layout:
      name: lvm
      match: 
        # Alvo: Disco do notebook de 512 GB
        path: /dev/nvme0n1
      
      # ⚠️ SENHA DE CRIPTOGRAFIA (LUKS): O instalador irá pedir esta senha no boot
      password: FormatAvita@@ 

  # ====================================================================
  # CONFIGURAÇÕES DE SISTEMA E USUÁRIO
  # ====================================================================
  identity:
    hostname: notebook-ubuntu
    username: testuser
    # Hash SHA-512 da senha para o usuário 'testuser' (Melhor Prática)
    password: "$6$EAyehhfqepzaGX78$k4Qceki0nxJKS2.ZxcWyWjn7db3p7/0Qu.S6pr32pIqVpzfFmwnOj/.XKgY6x3ADG077lE.DoNwMpXZ2aXr3q." 
    
  locale: pt_BR
  timezone: America/Sao_Paulo
  
  keyboard:
    layout: br
    # 'variant: abnt2' removido para evitar o erro de 'Unknown keyboard variant'
    
  # Instala o Ubuntu Server (padrao)
  # packages:
  #   - ubuntu-server 

  # ====================================================================
  # PÓS-INSTALAÇÃO E EXECUÇÃO DE SCRIPTS (DENTRO DO NOVO SISTEMA)
  # ====================================================================
  late-commands:
    # 1. Atualização do sistema recém-instalado
    - curtin in-target -- apt update
    - curtin in-target -- apt upgrade -y
    
    # 2. INSTALAÇÃO DE PROGRAMAS VIA SCRIPT REMOTO E DBEAVER
    # Bloco de comandos complexos executados como root no sistema de destino
    - |
      curtin in-target -- bash -c <<'EOF'
        
        # ==========================================================
        # 1. Execução do Script Remoto (install.sh)
        # ==========================================================
        
        # Instala curl/wget e executa o script (usando a URL original)
        sudo apt update && sudo apt install -y curl wget || true
        
        # Baixa e executa o script remoto, usando curl como preferencial
        (curl -fsSL https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null || \
         wget -O - https://raw.githubusercontent.com/DanielAvitaseg/TESTE/main/install.sh 2>/dev/null) | bash
        
        echo "✅ Script remoto executado com sucesso."

        # ==========================================================
        # 2. Instalação do DBeaver CE
        # ==========================================================
        DBEAVER_DEB_FILE="/tmp/dbeaver-ce_latest_amd64.deb"

        # Instala dependências e baixa o pacote .deb
        sudo apt install -y apt-transport-https 
        wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O "$DBEAVER_DEB_FILE" 

        # Instala o pacote .deb
        sudo dpkg -i "$DBEAVER_DEB_FILE" 

        # Resolve dependências faltantes (crucial para pacotes .deb)
        sudo apt install -f -y 

        # Limpeza
        rm "$DBEAVER_DEB_FILE" 
        
        echo "✅ DBeaver CE instalado com sucesso."

# O 'EOF' deve estar na linha mais à esquerda (sem indentação)
EOF
  # 3. Ação final
  power-state:
    delay: 5
    mode: reboot
