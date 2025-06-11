# Dockerfile (Versión Final de Producción)
FROM golang:1.24.0-alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
RUN git clone https://github.com/tailscale/tailscale.git .
RUN CGO_ENABLED=0 go build -o /derper ./cmd/derper

FROM alpine:latest
RUN apk add --no-cache ca-certificates openssl su-exec
RUN addgroup -S derper && adduser -S -G derper -h /home/derper derper
COPY --chown=derper:derper entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY --from=builder --chown=derper:derper /derper /usr/local/bin/derper
WORKDIR /home/derper
EXPOSE 443/tcp 3478/udp
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]