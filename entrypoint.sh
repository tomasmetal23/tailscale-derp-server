#!/bin/sh
# entrypoint.sh (Versión con Persistencia de Clave)

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# --- CONFIGURACIÓN DE PERSISTENCIA ---
# Definimos la ruta donde se guardará la clave.
# Esta ruta estará dentro de un volumen de Docker.
DATA_DIR="/home/derper/data"
KEY_FILE="${DATA_DIR}/derper.key"

log "Iniciando servidor DERP..."
log "Hostname: ${DERP_HOSTNAME}"

# --- LÓGICA DE CREACIÓN DE CLAVE SI NO EXISTE ---
if [ ! -f "$KEY_FILE" ]; then
    log "¡La clave privada no existe en ${KEY_FILE}!"
    log "Generando una nueva clave privada..."
    
    # Asegurarse de que el directorio de datos existe
    mkdir -p "$DATA_DIR"
    
    # Generar la clave con openssl, añadir el prefijo y guardarla en el archivo
    echo "private_key:$(openssl rand -hex 32)" > "$KEY_FILE"
    
    # Establecer permisos seguros para que solo el usuario derper pueda leerla
    chmod 600 "$KEY_FILE"
    
    log "Nueva clave privada guardada de forma segura."
else
    log "Usando la clave privada existente en ${KEY_FILE}."
fi

# --- EJECUCIÓN DEL SERVIDOR DERP ---
# Inicia el binario `derper` usando la clave persistente y las variables de entorno.
# Este método es más limpio que generar un archivo JSON.
log "Iniciando derper..."

exec /usr/local/bin/derper \
    -hostname "${DERP_HOSTNAME}" \
    -a "${DERP_ADDR:-:443}" \
    -stun-port "${DERP_STUN_PORT:-3478}" \
    -certmode "${DERP_CERT_MODE:-manual}" \
    -certdir "${DERP_CERT_DIR:-/certs}" \
    -verify-clients \
    -http-port -1 \
    -c "$KEY_FILE" # <-- ¡Aquí usamos nuestro archivo de clave persistente!