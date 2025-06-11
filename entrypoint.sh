#!/bin/sh
# entrypoint.sh (Versión Final y Simplificada)

set -e

# --- PARTE 1: GESTIÓN DE PERMISOS ---
# Usamos el directorio por defecto de derper, así no tenemos que decirle dónde buscar.
DEFAULT_DATA_DIR="/var/lib/derper"

# Si se ejecuta como root, arregla los permisos y cambia al usuario 'derper'.
# Esta es la única razón por la que el script es necesario.
if [ "$(id -u)" = '0' ]; then
    echo "Ejecutando como root, arreglando permisos para ${DEFAULT_DATA_DIR}..."
    
    # Crea el directorio y se lo asigna al usuario 'derper'.
    mkdir -p "$DEFAULT_DATA_DIR"
    chown -R derper:derper "$DEFAULT_DATA_DIR"
    
    echo "Permisos arreglados. Cambiando al usuario 'derper'..."
    # Vuelve a ejecutar este mismo script, pero ahora como el usuario 'derper'.
    exec su-exec derper "$0" "$@"
fi

# --- PARTE 2: EJECUCIÓN (Como usuario 'derper') ---
# Si llegamos aquí, ya somos el usuario correcto y los permisos están arreglados.

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iniciando servidor DERP (como usuario 'derper')..."

# --- ¡LA LÍNEA DE EJECUCIÓN FINAL Y LIMPIA! ---
# No hay generación de claves. No hay -c. Solo los flags de configuración.
# derper se encargará de crear y leer /var/lib/derper/derper.key automáticamente.
exec /usr/local/bin/derper \
    -hostname "${DERP_HOSTNAME}" \
    -a "${DERP_ADDR:-:443}" \
    -stun \
    -stun-port "${DERP_STUN_PORT:-3478}" \
    -certmode "manual" \
    -certdir "/certs" \
    -verify-clients \
    -http-port -1