# Etapa de construcción
FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache git ca-certificates

WORKDIR /src

# Clonar el repositorio y compilar
RUN git clone https://github.com/tailscale/tailscale.git . && \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 \
    go build -o derper ./cmd/derper

# Etapa final
FROM alpine:3.18

RUN apk add --no-cache ca-certificates tzdata && \
    adduser -D -s /bin/sh -u 1000 -h /home/derper derper && \
    mkdir -p /home/derper && \
    chown derper:derper /home/derper
    
ENV DERP_DOMAIN="localhost" \
    DERP_ADDR=":443" \
    DERP_STUN="true" \
    DERP_CERTMODE="manual" \
    DERP_CERTDIR="/certs" \
    DERP_HOSTNAME="" \
    DERP_STUN_PORT="3478" \
    DERP_HTTPS_PORT="443" \
    DERP_CERT="" \
    DERP_KEY="" \
    DERP_EXTRA=""

COPY --from=builder /src/derper /usr/local/bin/derper

# Copiar el script de entrada
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Crear directorio para certificados
RUN mkdir -p /certs && chown derper:derper /certs

USER derper
EXPOSE 443 3478/udp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]