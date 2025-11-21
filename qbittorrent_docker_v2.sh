#!/usr/bin/env bash
set -euo pipefail

echo "=== qBittorrent + Caddy Telepítő (Docker) ==="

# --- Root check ---
if [ "$EUID" -ne 0 ]; then
  echo "Ezt a scriptet rootként kell futtatni!"
  exit 1
fi

# --- Domain bekérése ---
read -rp "Add meg a domaint (pl. qb.domain.hu): " DOMAIN
if [ -z "$DOMAIN" ]; then
  echo "A domain nem lehet üres."
  exit 1
fi

INSTALL_DIR="/opt/qbittorrent-caddy"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "=== Hivatalos Docker repo hozzáadása ==="
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings || true

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y

echo "=== Docker + Compose telepítése ==="
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

echo "DOMAIN=${DOMAIN}" > .env

# --- docker-compose.yml ---
cat > docker-compose.yml <<'EOF'
version: "3.8"

services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Budapest
      - WEBUI_PORT=8080
    volumes:
      - ./qbittorrent/config:/config
      - ./qbittorrent/downloads:/downloads
    restart: unless-stopped

  caddy:
    image: caddy:latest
    container_name: caddy
    depends_on:
      - qbittorrent
    ports:
      - "80:80"
      - "443:443"
    environment:
      - DOMAIN=${DOMAIN}
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy_data:/data
      - ./caddy_config:/config
    restart: unless-stopped
EOF

# --- Caddyfile ---
cat > Caddyfile <<EOF
# HTTP -> HTTPS kötelező átirányítás
:80 {
  redir https://{host}{uri}
}

# IP-s elérés tiltása HTTPS-en
:443 {
  respond "Access via IP is disabled" 403
}

# DOMAIN -> qBittorrent reverse proxy
${DOMAIN} {
  encode gzip
  reverse_proxy qbittorrent:8080
}
EOF

echo "=== Konténerek indítása ==="
docker compose pull
docker compose up -d

echo "=== Várakozás a qBittorrent jelszóra... ==="

PASSWORD=""

# max 2 perc
for i in {1..60}; do
  PASSWORD=$(docker logs qbittorrent 2>&1 \
    | grep -oP "temporary password .*: \K.*" || true)

  if [ -n "$PASSWORD" ]; then
    break
  fi

  sleep 2
done

if [ -z "$PASSWORD" ]; then
  PASSWORD="NEM TALÁLHATÓ – futtasd: docker logs qbittorrent"
fi

# --- Összegzés ---
echo
echo "==========================================="
echo "        ✔ TELEPÍTÉS KÉSZ – ÖSSZEGZÉS"
echo "==========================================="
echo "Domain:            https://${DOMAIN}"
echo "WebUI:             https://${DOMAIN}"
echo "Felhasználónév:    admin"
echo "Jelszó:            ${PASSWORD}"
echo
echo "Telepítési könyvtár: ${INSTALL_DIR}"
echo "Konténer vezérlés:"
echo "  cd ${INSTALL_DIR}"
echo "  docker compose ps"
echo "  docker compose logs -f qbittorrent"
echo "  docker compose restart"
echo "==========================================="
echo
echo "HTTP → HTTPS átirányítás aktív."
echo "IP-címről 403 hibát kapsz — teljesen biztonságos!"
echo "A Let’s Encrypt tanúsítványt a Caddy automatikusan kezeli."
