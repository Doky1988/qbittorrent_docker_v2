# qBittorrent + Caddy Telepítő (Docker) — Debian 13

Ez a projekt egy teljesen automatizált telepítő scriptet tartalmaz, amellyel néhány perc alatt létrehozhatsz egy biztonságos, HTTPS-es, domainhez kötött qBittorrent seed szervert Caddy reverse proxyval és automatikus Let's Encrypt tanúsítványkezeléssel.

A script telepíti a Docker-t és a Docker Compose plugint, létrehozza a konténerkörnyezetet, beállítja a reverse proxyt, valamint kiolvassa a qBittorrent első indításkor generált WebUI jelszavát.

---

## 🚀 Funkciók

- Teljesen automatizált telepítés Debian 13 rendszeren  
- Docker + Docker Compose plugin automatikus telepítése  
- qBittorrent konténer beállítása  
- Caddy reverse proxy automatikus HTTPS-szel (Let's Encrypt)  
- HTTP → HTTPS kényszerített átirányítás  
- IP-címes elérés tiltása (403) — csak domainről érhető el  
- Automatikus qBittorrent WebUI jelszó-kinyerés a logból  
- Egyszerű konténerkezelés egyetlen könyvtárban  

---

## 📌 Ajánlott operációs rendszer

- **Debian 13 (tesztelve és ajánlott)**  
- Más Debian-alapú rendszereken is működhet, de tesztelve ezen lett.

---

## 📥 Telepítés

1. Hozz létre egy fájlt:  
   ```bash
   nano installer.sh

2. Másold bele a telepítő script teljes tartalmát, majd mentsd el!

3. Adj futási jogot:  
   ```bash
   chmod +x installer.sh

4. Futtasd:  
   ```bash
   sudo ./installer.sh

6. Add meg a domaint (pl. `torrent.domain.hu`).

---

## 🧩 Mi történik telepítés közben?

- Hivatalos Docker repository + kulcs hozzáadása  
- Docker + Docker Compose plugin telepítése  
- Telepítési mappa létrehozása:  
  `/opt/qbittorrent-caddy`
- `.env` fájl generálása a megadott domainnel  
- `docker-compose.yml` létrehozása:
  - `qbittorrent` konténer
  - `caddy` reverse proxy  
- `Caddyfile` automatikus létrehozása:
  - HTTPS + automatikus tanúsítványkezelés
  - kötelező HTTP → HTTPS redirect
  - IP-s elérés tiltása
- Konténerek letöltése és elindítása  
- qBittorrent log figyelése, ideiglenes WebUI-jelszó kinyerése  
- Telepítési összegzés megjelenítése

---

## 🔑 Telepítés utáni adatok

A script végén automatikusan kiírja:

- WebUI URL: `https://yourdomain.hu`  
- Felhasználónév: `admin`  
- Első jelszó (logból kinyerve)  
- Telepítési könyvtár helye  
- Hasznos docker compose parancsok (`ps`, `logs`, `restart`)  

---

## 📂 Fontos mappák

- **qBittorrent konfiguráció:**  
  `/opt/qbittorrent-caddy/qbittorrent/config`

- **Letöltések:**  
  `/opt/qbittorrent-caddy/qbittorrent/downloads`

- **Caddy adatfájlok (tanúsítványok, cache):**  
  `/opt/qbittorrent-caddy/caddy_data`

---

## ✍ Készítette

**Doky**  
2025
