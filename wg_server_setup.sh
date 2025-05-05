#!/bin/bash

WG_INTERFACE="wg0"
WG_ADDRESS="10.10.10.1/24"
WG_PORT=51820
INTERNET_INTERFACE="eth0" # Cambiar si tu interfaz de salida no es eth0
PEERS_FILE="/etc/wireguard/peers.conf"
SERVER_DIR="/etc/wireguard/servidor"
PRIVATE_KEY_FILE="$SERVER_DIR/privatekey"
PUBLIC_KEY_FILE="$SERVER_DIR/publickey"

# Crear claves si no existen
mkdir -p "$SERVER_DIR"

if [ ! -f "$PRIVATE_KEY_FILE" ]; then
  echo "[*] Generando claves del servidor..."
  wg genkey >"$PRIVATE_KEY_FILE"
  chmod 600 "$PRIVATE_KEY_FILE"
  cat "$PRIVATE_KEY_FILE" | wg pubkey >"$PUBLIC_KEY_FILE"
  chmod 600 "$PUBLIC_KEY_FILE"
fi

WG_PRIVATE_KEY=$(cat "$PRIVATE_KEY_FILE")
WG_PUBLIC_KEY=$(cat "$PUBLIC_KEY_FILE")

# Mostrar claves del servidor
echo "[*] Clave privada del servidor: $WG_PRIVATE_KEY"
echo "[*] Clave pública del servidor: $WG_PUBLIC_KEY"

# Eliminar interfaz si ya existe
ip link del "$WG_INTERFACE" 2>/dev/null

# Crear la interfaz
echo "[*] Creando interfaz WireGuard: $WG_INTERFACE"
ip link add dev "$WG_INTERFACE" type wireguard

# Asignar IP a la interfaz
ip address add dev "$WG_INTERFACE" "$WG_ADDRESS"

# Asignar puerto y clave privada
wg set "$WG_INTERFACE" listen-port "$WG_PORT" private-key <(echo "$WG_PRIVATE_KEY")

# Cargar peers desde archivo
if [ -f "$PEERS_FILE" ]; then
  echo "[*] Cargando peers desde $PEERS_FILE"
  while IFS= read -r line; do
    eval "$line"
  done <"$PEERS_FILE"
else
  echo "[!] No se encontró $PEERS_FILE. No se agregaron peers."
fi

# Levantar interfaz
ip link set up dev "$WG_INTERFACE"

# Habilitar IP forwarding
echo "[*] Habilitando IP forwarding"
sysctl -w net.ipv4.ip_forward=1
grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" >>/etc/sysctl.conf

# Agregar regla de enmascaramiento
iptables -t nat -C POSTROUTING -s 10.10.10.0/24 -o "$INTERNET_INTERFACE" -j MASQUERADE 2>/dev/null ||
  iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o "$INTERNET_INTERFACE" -j MASQUERADE

echo "[*] Configuracion de WireGuard finalizada."
