#!/usr/bin/env bash
set -euo pipefail

###################################################################################################
# qBittorrent + Caddy Update Script (Docker)
#
# 🔧 Hogyan használd?
#
# 1) Hozd létre a fájlt:
#      nano /opt/qbittorrent-caddy/update.sh
#
# 2) Másold bele ezt a scriptet → mentsd:
#      CTRL+O, ENTER, CTRL+X
#
# 3) Adj futási jogot:
#      chmod +x /opt/qbittorrent-caddy/update.sh
#
# 4) Indítsd el a frissítést:
#      sudo /opt/qbittorrent-caddy/update.sh
#
# Mit csinál?
#  - Letölti a legújabb qBittorrent + Caddy image-eket
#  - Frissíti a konténereket
#  - Törli a régi, felesleges image-eket
#
###################################################################################################

INSTALL_DIR="/opt/qbittorrent-caddy"

echo "=== qBittorrent + Caddy frissítés (Docker) ==="

# --- Root check ---
if [ "$EUID" -ne 0 ]; then
  echo "Ezt a scriptet rootként kell futtatni!"
  exit 1
fi

# --- Telepítési könyvtár ellenőrzése ---
if [ ! -d "$INSTALL_DIR" ]; then
  echo "Hiba: A telepítési könyvtár nem található: $INSTALL_DIR"
  exit 1
fi

cd "$INSTALL_DIR"

echo "=== Legújabb image-ek letöltése ==="
docker compose pull

echo "=== Konténerek frissítése ==="
docker compose up -d

echo "=== Régi image-ek törlése ==="
docker image prune -f

echo
echo "==========================================="
echo "  ✔ Frissítés befejezve"
echo "==========================================="
docker compose ps
echo
