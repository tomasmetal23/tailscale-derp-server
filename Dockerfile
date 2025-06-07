# ────────── etapa de compilación ──────────
# Buildx inyectará BUILDPLATFORM/TARGETPLATFORM automáticamente
FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH

# Opcional: git se usa para bajar dependencias indirectas
RUN apk add --no-cache git

WORKDIR /src
# Compilación estática, sin CGO → binario pequeño y portable
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 \
    go install tailscale.com/cmd/derper@latest

# ────────── etapa de ejecución ────────────
FROM alpine:3.20
RUN apk add --no-cache ca-certificates

USER 1000:1000

# Valores por defecto que puedes sobreescribir con variables
ENV DERP_ADDR=":3478" \
    DERP_STUN_PORT="3478" \
    DERP_HTTPS_PORT="8443" \
    DERP_CERT="/certs/fullchain.pem" \
    DERP_KEY="/certs/privkey.pem" \
    DERP_EXTRA=""

COPY --from=builder /go/bin/derper /usr/local/bin/derper

ENTRYPOINT ["/usr/local/bin/derper"]
CMD ["sh","-c", "\
  exec /usr/local/bin/derper \
    -a ${DERP_ADDR} \
    -stun-port ${DERP_STUN_PORT} \
    -https-port ${DERP_HTTPS_PORT} \
    -cert ${DERP_CERT} \
    -key  ${DERP_KEY} \
    -verify-clients ${DERP_EXTRA}"]