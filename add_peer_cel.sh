#!/bin/bash

read -p "Nombre del cliente móvil: " CLIENT_NAME
read -p "IP interna del cliente (ej: 10.10.10.2/32): " CLIENT_IP

SERVER_PUBLIC_KEY=$(cat /etc/wireguard/servidor/publickey)
SERVER_ENDPOINT="test.duckdns.org:51820" # CAMBIAR EL DNS
WG_INTERFACE="wg0"
PEERS_FILE="/etc/wireguard/peers.conf"
CLIENT_DIR="/etc/wireguard/celularar/$CLIENT_NAME"
CLIENT="wg0"

mkdir -p "$CLIENT_DIR"

# Generar claves para el cliente
wg genkey >"$CLIENT_DIR/privatekey"
cat "$CLIENT_DIR/privatekey" | wg pubkey >"$CLIENT_DIR/publickey"
chmod 600 "$CLIENT_DIR/"*

CLIENT_PRIVATE_KEY=$(cat "$CLIENT_DIR/privatekey")
CLIENT_PUBLIC_KEY=$(cat "$CLIENT_DIR/publickey")

# Agregar peer en el servidor
wg set "$WG_INTERFACE" peer "$CLIENT_PUBLIC_KEY" allowed-ips "$CLIENT_IP"

# Guardar peer en peers.conf para persistencia
echo "wg set $WG_INTERFACE peer $CLIENT_PUBLIC_KEY allowed-ips $CLIENT_IP" >>"$PEERS_FILE"

# Crear archivo de configuracion
cat >"$CLIENT_DIR/${CLIENT}.conf" <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 10.1.1.112/32, 10.1.1.113/32, 10.1.1.119/32, 10.1.1.1/32, 0.0.0.0/0
PersistentKeepalive = 25
EOF

chmod 600 "$CLIENT_DIR/${CLIENT}.conf"

# Generar QR
if ! command -v qrencode >/dev/null 2>&1; then
  echo "[*] Instalando qrencode..."
  apt update
  apt install -y qrencode
fi

qrencode -t png -o "$CLIENT_DIR/${CLIENT}.png" <"$CLIENT_DIR/${CLIENT}.conf"

echo "[*] Cliente movil $CLIENT_NAME generado."
echo "[*] Configuracion: $CLIENT_DIR/${CLIENT}.conf"
echo "[*] Codigo QR: $CLIENT_DIR/${CLIENT}.png"
echo ">> Escanea el código QR con la app de WireGuard"
