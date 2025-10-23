#!/bin/bash

# Este script tenta remover pacotes Snap e Flatpak para uma lista de aplicações,
# assumindo que você deseja manter a versão APT (ou outra versão, se houver).
#
# !! USE POR SUA CONTA E RISCO. FAÇA UM BACKUP ANTES DE EXECUTAR !!
#

PROGRAMAS=(
    "dbeaver-ce"      # DBeaver
    "postman"         # Postman
    "slack"           # Slack
    "code"            # Visual Studio Code (VS Code)
    "powershell"      # PowerShell
    # Os outros programas (Docker, NVM, .NET Core, Intune) têm nomes/instalações mais complexos e
    # não são incluídos aqui para evitar quebras. Verifique-os manualmente.
)

FLATPAK_PROGRAMAS=(
    "io.dbeaver.DBeaverCommunity"
    "com.getpostman.Postman"
    "com.slack.Slack"
    "com.visualstudio.code"
)

echo "--- INÍCIO DA LIMPEZA DE DUPLICATAS ---"
echo "OBS: Serão removidas as versões Snap e Flatpak para os programas listados."
echo ""

# Função para remover pacotes Snap
remover_snap() {
    local nome_snap=$1
    if snap list | grep -w "$nome_snap" &> /dev/null; then
        echo "--> Removendo Snap: $nome_snap"
        sudo snap remove "$nome_snap"
    else
        echo "Snap $nome_snap não encontrado."
    fi
}

# Função para remover pacotes Flatpak
remover_flatpak() {
    local nome_flatpak=$1
    if flatpak list | grep -w "$nome_flatpak" &> /dev/null; then
        echo "--> Removendo Flatpak: $nome_flatpak"
        flatpak remove "$nome_flatpak" -y
    else
        echo "Flatpak $nome_flatpak não encontrado."
    fi
}

# --- 1. REMOVER SNAPS ---
echo "======================================="
echo "INICIANDO REMOÇÃO DE PACOTES SNAP..."
echo "======================================="

for app in "${PROGRAMAS[@]}"; do
    remover_snap "$app"
done

# --- 2. REMOVER FLATPAKS ---
echo ""
echo "======================================="
echo "INICIANDO REMOÇÃO DE PACOTES FLATPAK..."
echo "======================================="

for app in "${FLATPAK_PROGRAMAS[@]}"; do
    remover_flatpak "$app"
done

echo ""
echo "--- LIMPEZA CONCLUÍDA. ---"
echo "Pode ser necessário reiniciar o sistema ou o ambiente gráfico para que os ícones duplicados desapareçam."
