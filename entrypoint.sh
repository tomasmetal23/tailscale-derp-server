#!/bin/sh
set -e

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting DERP server configuration..."

# Construir argumentos dinámicamente
ARGS=""

# Hostname (prioritario desde DERP_EXTRA si está presente)
if [ -n "$DERP_HOSTNAME" ]; then
    ARGS="$ARGS -hostname=$DERP_HOSTNAME"
elif [ -n "$DERP_DOMAIN" ]; then
    ARGS="$ARGS -hostname=$DERP_DOMAIN"
fi

# Dirección de escucha
if [ -n "$DERP_ADDR" ]; then
    ARGS="$ARGS -a=$DERP_ADDR"
fi

# Puerto HTTP específico (disable con -1)
if [ -n "$DERP_HTTPS_PORT" ]; then
    ARGS="$ARGS -http-port=$DERP_HTTPS_PORT"
fi

# STUN habilitado
if [ "$DERP_STUN" = "true" ]; then
    ARGS="$ARGS -stun"
fi

# Puerto STUN específico
if [ -n "$DERP_STUN_PORT" ]; then
    ARGS="$ARGS -stun-port=$DERP_STUN_PORT"
fi

# Modo de certificados
if [ -n "$DERP_CERTMODE" ]; then
    ARGS="$ARGS -certmode=$DERP_CERTMODE"
fi

# Directorio de certificados (solo este, no archivos específicos)
if [ -n "$DERP_CERTDIR" ]; then
    ARGS="$ARGS -certdir=$DERP_CERTDIR"
fi

# Verificar que el directorio de certificados exista
if [ -n "$DERP_CERTDIR" ] && [ ! -d "$DERP_CERTDIR" ]; then
    log "ERROR: Certificate directory not found: $DERP_CERTDIR"
    exit 1
fi

# Argumentos extra (se añaden al final)
if [ -n "$DERP_EXTRA" ]; then
    ARGS="$ARGS $DERP_EXTRA"
fi

log "DERP server arguments: $ARGS"
log "Starting DERP server..."

# Ejecutar derper con los argumentos construidos
exec /usr/local/bin/derper $ARGS