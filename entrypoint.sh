#!/bin/sh
# entrypoint.sh (Versión con Corrección de Permisos y Descenso de Privilegios)

set -e

# --- NUEVA SECCIÓN: GESTIÓN DE PERMISOS Y USUARIO ---

# Ruta al directorio de datos persistentes.
DATA_DIR="/home/derper/data"

# Si el script se ejecuta como root (UID 0), arregla los permisos
# y luego vuelve a ejecutar el script como el usuario 'derper'.
if [ "$(id -u)" = '0' ]; then
    echo "Ejecutando como root, arreglando permisos..."
    
    # Asegurarse de que el directorio de datos existe y pertenece a 'derper'.
    # Esto soluciona el problema del montaje de volúmenes por parte de Docker como root.
    mkdir -p "$DATA_DIR"
    chown -R derper:derper "$DATA_DIR"
    
    echo "Permisos arreglados. Cambiando al usuario 'derper'..."
    # Vuelve a ejecutar este mismo script, pero ahora como el usuario 'derper'.
    # "$@" pasa todos los argumentos originales.
    exec su-exec derper "$0" "$@"
fi

# Si llegamos aquí, ya no somos root, somos el usuario 'derper'.
# El resto del script se ejecuta con los privilegios correctos.

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

KEY_FILE="${DATA_DIR}/derper.key"

log "Iniciando servidor DERP (como usuario derper)..."
log "Hostname: ${DERP_HOSTNAME}"

if [ ! -f "$KEY_FILE" ]; then
    log "¡La clave privada no existe en ${KEY_FILE}!"
    log "Generando una nueva clave privada..."
    
    # Esta operación ahora tendrá éxito porque 'derper' es dueño de DATA_DIR.
    echo "private_key:$(openssl rand -hex 32)" > "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    
    log "Nueva clave privada guardada de forma segura."
else
    log "Usando la clave privada existente en ${KEY_FILE}."
fi

log "Iniciando derper..."

exec /usr/local/bin/derper \
    -hostname "${DERP_HOSTNAME}" \
    -a "${DERP_ADDR:-:443}" \
    -stun-port "${DERP_STUN_PORT:-3478}" \
    -certmode "${DERP_CERT_MODE:-manual}" \
    -certdir "${DERP_CERT_DIR:-/certs}" \
    -verify-clients \
    -http-port -1 \
    -c "$KEY_FILE"