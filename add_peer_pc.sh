#!/bin/bash

#CRER SCRIPT PARA NO USAR wg-quick

read -p "Nombre del cliente: " CLIENT_NAME
read -p "IP interna del cliente (ej: 10.10.10.2/32): " CLIENT_IP

SERVER_PUBLIC_KEY=$(cat /etc/wireguard/servidor/publickey)
SERVER_ENDPOINT="test.duckdns.org:51820" # CAMBIAR EL DNS
WG_INTERFACE="wg0"
PEERS_FILE="/etc/wireguard/peers.conf"
CLIENT_DIR="/etc/wireguard/client/pc/$CLIENT_NAME"
CLIENT="wg0"

mkdir -p "$CLIENT_DIR"

# Generar claves del cliente
wg genkey >"$CLIENT_DIR/privatekey"
cat "$CLIENT_DIR/privatekey" | wg pubkey >"$CLIENT_DIR/publickey"
chmod 600 "$CLIENT_DIR/"*

CLIENT_PRIVATE_KEY=$(cat "$CLIENT_DIR/privatekey")
CLIENT_PUBLIC_KEY=$(cat "$CLIENT_DIR/publickey")

# Agregar peer en el servidor
wg set "$WG_INTERFACE" peer "$CLIENT_PUBLIC_KEY" allowed-ips "$CLIENT_IP"

# Guardar peer en peers.conf para persistencia
echo "wg set $WG_INTERFACE peer $CLIENT_PUBLIC_KEY allowed-ips $CLIENT_IP" >>"$PEERS_FILE"

# Crear script de configuracion del cliente
cat >"$CLIENT_DIR/configurar-${CLIENT}.sh" <<EOF

#!/bin/bash

# Verificar e instalar dependencias
if ! command -v wg >/dev/null 2>&1; then
    echo "[*] Instalando wireguard..."
    apt update
    apt install -y wireguard
fi

if ! command -v resolvconf >/dev/null 2>&1; then
    echo "[*] Instalando resolvconf..."
    apt install -y resolvconf
fi

mkdir -p /etc/wireguard

cat > /etc/wireguard/${CLIENT}.conf <<EOCONF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 10.1.1.112/32, 10.1.1.113/32, 10.1.1.119/32, 10.1.1.1/32, 0.0.0.0/0
PersistentKeepalive = 25
EOCONF

chmod 600 /etc/wireguard/${CLIENT}.conf

echo "[*] Configuración creada en /etc/wireguard/${CLIENT}.conf"
echo ">> Ejecutá: wg-quick up ${CLIENT} para iniciar la VPN"

rm configurar-${CLIENT}.sh

EOF

chmod +x "$CLIENT_DIR/configurar-${CLIENT}.sh"

echo "[*] Cliente $CLIENT_NAME generado."
echo "[*] Script de configuración: $CLIENT_DIR/configurar-${CLIENT}.sh"
