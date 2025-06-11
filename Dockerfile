# Dockerfile (MODO DEPURACIÓN - TODO COMO ROOT)
FROM golang:1.24.0-alpine AS builder
RUN apk add --no-cache git
WORKDIR /app
RUN git clone https://github.com/tailscale/tailscale.git .
RUN CGO_ENABLED=0 go build -o /derper ./cmd/derper

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /derper /usr/local/bin/derper
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]