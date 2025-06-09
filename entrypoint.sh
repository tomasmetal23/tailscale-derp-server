#!/bin/sh
# entrypoint.sh (Versión Final y Corregida)

set -e

# Imprimir un log con fecha
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Iniciando servidor DERP..."

# --- PUNTO CRÍTICO: INCLUIMOS LA CLAVE PRIVADA ---
# El script ahora lee DERP_PRIVATE_KEY del entorno
if [ -z "$DERP_PRIVATE_KEY" ]; then
    log "ERROR: La variable de entorno DERP_PRIVATE_KEY no está definida."
    exit 1
fi

CONFIG_FILE="/tmp/derper.json"

log "Creando archivo de configuración en $CONFIG_FILE"

# --- PUNTO CRÍTICO 2: GENERAMOS EL JSON COMPLETO Y CORRECTO ---
# Este JSON ahora contiene la clave privada.
# Y usa los nombres de variable correctos (con guiones bajos).
cat > "$CONFIG_FILE" << EOF
{
  "hostname": "${DERP_HOSTNAME}",
  "addr": "${DERP_ADDR}",
  "stun": true,
  "stun_port": 3478,
  "http_port": -1,
  "cert_mode": "${DERP_CERT_MODE}",
  "cert_dir": "${DERP_CERT_DIR}",
  "verify_clients": ${DERP_VERIFY_CLIENTS},
  "private_key": "${DERP_PRIVATE_KEY}"
}
EOF

log "Configuración generada:"
cat "$CONFIG_FILE"

# --- PUNTO CRÍTICO 3: EJECUTAMOS EL BINARIO DESDE LA RUTA CORRECTA ---
# Y le pasamos el archivo de configuración con el flag -c
log "Iniciando derper con el archivo de configuración..."
exec /usr/local/bin/derper -c "$CONFIG_FILE"