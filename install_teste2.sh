#cloud-config
autoinstall:
  version: 1
  
  # ====================================================================
  # CONFIGURAÇÃO DE ARMAZENAMENTO (LVM sobre LUKS)
  # ====================================================================
  storage:
    wipe: all
    layout:
      name: lvm
      match: 
        path: /dev/nvme0n1
      # SENHA DE CRIPTOGRAFIA (LUKS): USE SUA SENHA FORTE AQUI
      password: Senhafoda123@ 

  # ====================================================================
  # CONFIGURAÇÕES DE SISTEMA
  # ====================================================================
  identity:
    hostname: notebook-ubuntu
    username: testuser
    # Hash SHA-512 da senha (Mais seguro que plaintext_password)
    password: "$6$EAyehhfqepzaGX78$k4Qceki0nxJKS2.ZxcWyWjn7db3p7/0Qu.S6pr32pIqVpzfFmwnOj/.XKgY6x3ADG077lE.DoNwMpXZ2aXr3q." 
    
  locale: pt_BR
  timezone: America/Sao_Paulo
  
  keyboard:
    layout: br
    # 'variant: abnt2' removido para evitar o erro de 'Unknown keyboard variant'

  # ====================================================================
  # PÓS-INSTALAÇÃO E EXECUÇÃO DE SCRIPT
  # ====================================================================
  late-commands:
    # 1. Comando Base de Atualização (Mantido)
    - curtin in-target -- apt update
    - curtin in-target -- apt upgrade -y
    
    # 2. INSTALAÇÃO DE PROGRAMAS VIA SCRIPT REMOTO
    # Baixa o script 'install.sh' e o executa dentro do sistema instalado (/target).
    - |
      # URL do script (Note que 'refs/heads/main' é mais estável que 'master')
      SCRIPT_URL="https://raw.githubusercontent.com/DanielAvitaseg/TESTE/refs/heads/main/install.sh"
      SCRIPT_PATH="/tmp/install.sh"
      
      # Baixa o script usando curl (geralmente mais comum em ambientes de servidor)
      /usr/bin/curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"
      
      # Executa o script dentro do sistema instalado (chroot)
      # O shell 'curtin in-target -- bash' garante que estamos no ambiente correto
      curtin in-target -- bash "$SCRIPT_PATH"
      
    # 3. Ação final (Deve ser a última)
  power-state:
    delay: 5
    mode: reboot
