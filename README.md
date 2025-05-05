# WireGuard VPN Server Setup

## 📌 Descripción

Script para configurar automáticamente un servidor WireGuard VPN con funcionalidades completas:

```bash
wg_server_setup.sh
```

## 🌟 Características principales

    ✔️ Configuración automática de interfaz WireGuard

    ✔️ Generación segura de claves pública/privada

    ✔️ Administración centralizada de peers

    ✔️ Configuración de NAT y forwarding

    ✔️ Persistencia después de reinicios

## 🛠 Requisitos

- Sistema operativo basado en Linux (Ubuntu/Debian recomendado)

- Acceso root o sudo

- Conexión a internet activa

- Puerto UDP $WG_PORT (51820 por defecto) accesible

## 📋 Parámetros configurables

| variable             | valor por defecto | Descripción                   |
| -------------------- | ----------------- | ----------------------------- |
| `WG_INTERFACE`       | wg0               | Nombre de la interfaz VPN     |
| `WG_ADDRESS`         | 10.10.10.1/24     | IP/máscara del servidor       |
| `WG_PORT`            | 51820             | Puerto de escucha WireGuard   |
| `INTERNET_INTERFACE` | eth0              | Interfaz de salida a internet |

## 🚀 Instalación y ejecución

1. Descargar el script:

```bash
wget https://github.com/RagnarKnight/wireguard.git

```

2. Dar permisos de ejecución:

```bash
chmod +x wg_server_setup.sh
```

3. Ejecutar como root:

```bash

sudo ./wg_server_setup.sh

```

## 📂 Estructura de archivos generados

```bash
/etc/wireguard/
├── servidor/
│ ├── privatekey  # Clave privada del servidor
│ └── publickey   # Clave pública del servidor
│── client
│ ├── celular     # Clientes para celulares
│ └── pc          # Clientes para pc
│
└── peers.conf    # Listado de peers registrados
```

## 🔧 Comandos útiles para los clientes

1.  Verificar estado de la VPN:

```bash
wg show
```

2. Reiniciar la interfaz:

```bash

wg-quick down wg0 && wg-quick up wg0
```

## ⚠️ Consideraciones de seguridad

- Las claves generadas se almacenan con permisos 600

- Se recomienda rotar las claves periódicamente

- El archivo peers.conf contiene comandos sensibles

- Usar IPs únicas para cada cliente en la red 10.10.10.0/24

## 🔄 Integración con otros scripts

Este servidor funciona perfectamente con:

`add_peer.sh` - Para clientes Linux/Windows

`add_peer_cel.sh` - Para clientes móviles con QR

## 📜 Licencia

Este proyecto está licenciado bajo la [Licencia Creative Commons Atribución-CompartirIgual 4.0 Internacional](https://creativecommons.org/licenses/by-sa/4.0/) - consulta el archivo [LICENSE](LICENSE) para más detalles.
# wireguard
