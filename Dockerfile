# Dockerfile Simplificado (KISS)

FROM golang:1.24.0-alpine

# Instalar solo las dependencias mínimas para construir
RUN apk add --no-cache git

# Crear usuario no-root por seguridad
RUN adduser -D -s /bin/sh -u 1000 -h /home/derper derper

# Cambiar al usuario y directorio de trabajo
USER derper
WORKDIR /home/derper

# Instalar el binario de derper. Se guardará en /home/derper/go/bin/
RUN go install tailscale.com/cmd/derper@main

# Exponer los puertos que usará el servicio
EXPOSE 443/tcp 3478/udp

# El Entrypoint es simplemente el programa que queremos ejecutar.
# Docker le pasará las variables de entorno para que se configure solo.
ENTRYPOINT ["/home/derper/go/bin/derper"]