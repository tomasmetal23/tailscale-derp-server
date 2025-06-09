#!/bin/sh
set -eu

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

###############################################################################
# Rutas y ajustes
###############################################################################
CONFIG_FILE="/tmp/derper.json"
HOSTNAME="${DERP_HOSTNAME:-derp.saiyans.com.ve}"

STATE_DIR="${DERP_STATE_DIR:-/state}"     # volumen persistente
NODE_KEY_FILE="$STATE_DIR/node.key"       # aquí guardamos la clave

CERT_DIR="${DERP_CERTDIR:-/certs}"        # tus certs (modo manual)

###############################################################################
# Preparar directorios y Node Key
###############################################################################
mkdir -p "$STATE_DIR"
export HOME="$STATE_DIR"                  # futuro-proof; no molesta

if [ ! -f "$NODE_KEY_FILE" ]; then
    log "No existe node.key… generando una nueva"
    /usr/local/bin/derper -generate-key > "$NODE_KEY_FILE"
    chmod 600 "$NODE_KEY_FILE"
else
    log "Usando node.key existente: $NODE_KEY_FILE"
fi

###############################################################################
# Crear archivo de configuración
###############################################################################
log "Creando archivo de configuración…"

cat > "$CONFIG_FILE" <<EOF
{
  "hostname": "$HOSTNAME",
  "addr": "${DERP_ADDR:-:443}",
  "stun": ${DERP_STUN:-true},
  "stun_port": ${DERP_STUN_PORT:-3478},
  "http_port": ${DERP_HTTPS_PORT:--1},
  "cert_mode": "<span class="ml-2" /><span class="inline-block w-3 h-3 rounded-full bg-neutral-a12 align-middle mb-[0.1rem]" />