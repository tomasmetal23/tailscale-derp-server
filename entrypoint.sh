#!/bin/sh
set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting DERP server configuration..."

# Crear archivo de configuración
CONFIG_FILE="/tmp/derper.json"
HOSTNAME="${DERP_HOSTNAME:-derp.saiyans.com.ve}"

log "Creating configuration file..."
log "Hostname: $HOSTNAME"
log "Address: ${DERP_ADDR:-:443}"
log "Cert directory: ${DERP_CERTDIR:-/certs}"

# Generar el archivo de configuración JSON
cat > "$CONFIG_FILE" << EOF
{
  "hostname": "$HOSTNAME",
  "addr": "${DERP_ADDR:-:443}",
  "stun": ${DERP_STUN:-true},
  "stun_port": ${DERP_STUN_PORT:-3478},
  "http_port": ${DERP_HTTPS_PORT:--1},
  "cert_mode": "${DERP_CERTMODE:-manual}",
  "cert_dir": "${DERP_CERTDIR:-/certs}"
}
EOF

log "Generated configuration:"
cat "$CONFIG_FILE"

# Verificar directorio de certificados
if [ ! -d "${DERP_CERTDIR:-/certs}" ]; then
    log "ERROR: Certificate directory not found: ${DERP_CERTDIR:-/certs}"
    exit 1
fi

log "Starting DERP server with configuration file..."
exec /usr/local/bin/derper -c "$CONFIG_FILE"