FROM golang:1.24.0-alpine

# Instalar dependencias necesarias
RUN apk add --no-cache git ca-certificates tzdata

# Crear usuario derp
RUN adduser -D -s /bin/sh -u 1000 -h /home/derper derper

# Cambiar al usuario derper
USER derper
WORKDIR /home/derper

# Instalar DERP server
RUN go install tailscale.com/cmd/derper@main

# Copiar entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Variables de entorno por defecto
ENV DERP_ADDR=":443"
ENV DERP_HOSTNAME="derp.saiyans.com.ve"
ENV DERP_STUN="true"
ENV DERP_STUN_PORT="3478"
ENV DERP_HTTPS_PORT="-1"
ENV DERP_CERTMODE="manual"
ENV DERP_CERTDIR="/certs"
ENV DERP_VERIFY_CLIENTS="false"

# Exponer los puertos
EXPOSE 443/tcp 3478/udp

# Configurar entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]