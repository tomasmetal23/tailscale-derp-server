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
    adduser -D -s /bin/sh -u 1000 derper

ENV DERP_DOMAIN="localhost" \
    DERP_ADDR=":443" \
    DERP_STUN="true" \
    DERP_CERTMODE="manual" \
    DERP_CERTDIR="/app/certs" \
    DERP_HOSTNAME="" \
    DERP_STUN_PORT="3478" \
    DERP_KEY="" \
    DERP_EXTRA=""

COPY --from=builder /src/derper /usr/local/bin/derper

USER derper
EXPOSE 8443 3478/udp

ENTRYPOINT ["/usr/local/bin/derper"]