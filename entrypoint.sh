#!/bin/sh
# entrypoint.sh (Versión Final de Producción)

set -e

# --- Gestión de Permisos y Usuario ---
DATA_DIR="/home/derper/data"
if [ "$(id -u)" = '0' ]; then
    mkdir -p "$DATA_DIR"
    chown -R derper:derper "$DATA_DIR"
    exec su-exec derper "$0" "$@"
fi

# --- Lógica Principal como usuario 'derper' ---
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

KEY_FILE="${DATA_DIR}/derper.key"
CONFIG_FILE="/tmp/derper.json"

log "Iniciando servidor DERP..."

# --- Gestión de la Clave de Identidad (Obligatoria) ---
if [ ! -f "$KEY_FILE" ]; then
    log "Generando clave de identidad persistente en ${KEY_FILE}..."
    openssl rand -hex 32 > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
else
    log "Usando clave de identidad existente de ${KEY_FILE}."
fi

# --- Construcción del JSON Completo (Obligatorio) ---
log "Construyendo archivo de configuración JSON en ${CONFIG_FILE}..."
PRIVATE_KEY="private_key:$(cat ${KEY_FILE})"

cat > "$CONFIG_FILE" << EOF
{
  "hostname": "${DERP_HOSTNAME}",
  "addr": "${DERP_ADDR:-:443}",
  "stun": true,
  "stun_port": ${DERP_STUN_PORT:-3478},
  "http_port": -1,
  "cert_mode": "manual",
  "cert_dir": "/certs",
  "verify_clients": ${DERP_VERIFY_CLIENTS:-true},
  "private_key": "${PRIVATE_KEY}"
}
EOF

log "Configuración JSON generada."

# --- Ejecución Final con -c ---
log "Iniciando derper..."
exec /usr/local/bin/derper -c "$CONFIG_FILE"