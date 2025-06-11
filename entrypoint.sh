#!/bin/sh
# entrypoint.sh (MODO DEPURACIÓN - JSON sin clave, ejecutado como ROOT)

set -e

CONFIG_FILE="/tmp/derper.json"

echo "[DEBUG] Construyendo configuración JSON sin clave privada..."
cat > "$CONFIG_FILE" << EOF
{
  "hostname": "${DERP_HOSTNAME}",
  "addr": "${DERP_ADDR:-:443}",
  "stun": true,
  "stun_port": ${DERP_STUN_PORT:-3478},
  "http_port": -1,
  "cert_mode": "manual",
  "cert_dir": "/certs",
  "verify_clients": true
}
EOF

echo "[DEBUG] Configuración generada:"
cat "$CONFIG_FILE"

echo "[DEBUG] Iniciando derper como root con -c ${CONFIG_FILE}..."
exec /usr/local/bin/derper -c "$CONFIG_FILE"