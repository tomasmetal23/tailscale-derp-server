# --- FASE 1: El Constructor (Builder) ---
# Usamos la imagen completa de Go para compilar. Le ponemos un alias "builder".
FROM golang:1.24.0-alpine AS builder

# Instalar git, que es necesario para clonar el repositorio
RUN apk add --no-cache git

# Establecer el directorio de trabajo
WORKDIR /app

# Clonar el código fuente de Tailscale
RUN git clone https://github.com/tailscale/tailscale.git .

# Compilar el binario de derper.
# CGO_ENABLED=0 crea un binario estático que no depende de librerías C del sistema.
# -o /derper guarda el binario compilado en la raíz con el nombre "derper".
RUN CGO_ENABLED=0 go build -o /derper ./cmd/derper


# --- FASE 2: La Imagen Final (Final Stage) ---
# Empezamos desde una imagen base súper ligera. Alpine es perfecta.
FROM alpine:latest

# Instalar solo los certificados CA, necesarios para conexiones HTTPS.
RUN apk add --no-cache ca-certificates

# Crear un grupo y un usuario no-root por seguridad
RUN addgroup -S derper && adduser -S -G derper -h /home/derper derper

# Copiar el script de entrada. --chown se asegura de que el dueño sea el usuario correcto.
COPY --chown=derper:derper entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# --- LA MAGIA DEL MULTI-STAGE ---
# Copiar SOLO el binario compilado desde la fase "builder".
COPY --from=builder --chown=derper:derper /derper /usr/local/bin/derper

# Cambiar al usuario no-root
USER derper
WORKDIR /home/derper

# Exponer los puertos
EXPOSE 443/tcp 3478/udp

# Establecer el punto de entrada para ejecutar nuestro script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]