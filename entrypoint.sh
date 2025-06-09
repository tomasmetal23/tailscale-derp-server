#!/bin/sh
set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting DERP server configuration..."

# Crear archivo de configuración
CONFIG_FILE="/tmp/derper.json"
HOSTNAME="${DERP_HOSTNAME}"

log "Creating configuration file..."
log "Hostname: $HOSTNAME"
log "Address: ${DERP_ADDR}"
log "Cert directory: ${DERP_CERTDIR}"

# Generar el archivo de configuración JSON
cat > "$CONFIG_FILE" << EOF
{
  "hostname": "$HOSTNAME",
  "addr": "${DERP_ADDR}",
  "stun": ${DERP_STUN},
  "stun_port": ${DERP_STUN_PORT},
  "http_port": ${DERP_HTTPS_PORT},
  "cert_mode": "${DERP_CERTMODE}",
  "cert_dir": "${DERP_CERTDIR}",
  "verify_clients": ${DERP_VERIFY_CLIENTS}
}
EOF

log "Generated configuration:"
cat "$CONFIG_FILE"

# Verificar directorio de certificados
if [ ! -d "${DERP_CERTDIR}" ]; then
    log "ERROR: Certificate directory not found: ${DERP_CERTDIR}"
    exit 1
fi

log "Starting DERP server with configuration file..."
exec /home/derper/go/bin/derper -c "$CONFIG_FILE"