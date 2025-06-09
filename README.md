# Tailscale DERP Server Docker Image

A lightweight, multi-architecture Docker image for running your own Tailscale DERP (Designated Encrypted Relay for Packets) server.

## Features

- 🏗️ Multi-architecture support (amd64, arm64)
- 🔒 Runs as non-root user for security
- 📦 Based on Alpine Linux (minimal size)
- 💾 Persistent server identity (node key)
- 🔐 Support for manual TLS certificates

## Quick Start

### 1. Prepare directories

```bash
# Create required directories
mkdir -p state certs

# Set permissions for the state directory (container runs as UID 1000)
sudo chown 1000:1000 state
```

### 2. Add your certificates

Place your TLS certificate and key in the `certs` directory:

```
certs/
├── derp.example.com.crt
└── derp.example.com.key
```

### 3. Create docker-compose.yml

```yaml
version: '3.8'

services:
  derp:
    image: ghcr.io/yourusername/derper:latest
    container_name: tailscale-derper
    restart: unless-stopped
    environment:
      - DERP_HOSTNAME=derp.example.com
      - DERP_ADDR=:443
      - DERP_STUN=true
      - DERP_CERTMODE=manual
    volumes:
      - ./state:/state
      - ./certs:/certs:ro
    ports:
      - "443:443"
      - "3478:3478/udp"
```

### 4. Start the server

```bash
docker compose up -d
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DERP_HOSTNAME` | FQDN of your DERP server | `derp.example.com` |
| `DERP_ADDR` | Listen address | `:443` |
| `DERP_STUN` | Enable STUN server | `true` |
| `DERP_STUN_PORT` | STUN UDP port | `3478` |
| `DERP_CERTMODE` | Certificate mode | `manual` |
| `DERP_CERTDIR` | Certificate directory | `/certs` |

## Configure Tailscale to use your DERP

Add this to your Tailscale ACL configuration:

```json
{
  "derpMap": {
    "regions": {
      "900": {
        "regionID": 900,
        "regionCode": "myderp",
        "regionName": "My DERP",
        "nodes": [
          {
            "name": "derp1",
            "regionID": 900,
            "hostname": "derp.example.com",
            "derpPort": 443,
            "stunPort": 3478,
            "stunOnly": false
          }
        ]
      }
    }
  }
}
```

## Directory Structure

```
./
├── docker-compose.yml
├── state/              # Persistent data (auto-created)
│   └── node.key        # Server identity (auto-generated)
└── certs/              # Your TLS certificates
    ├── derp.example.com.crt
    └── derp.example.com.key
```

## Building from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/derper-docker
cd derper-docker

# Build for multiple architectures
docker buildx build --platform linux/amd64,linux/arm64 \
  -t ghcr.io/yourusername/derper:latest --push .

# Or build for local use
docker build -t derper:latest .
```

## Troubleshooting

### Check logs
```bash
docker logs tailscale-derper
```

### Test connectivity
```bash
# Test HTTPS
curl https://derp.example.com/derp/probe

# Test STUN
nc -u -v derp.example.com 3478
```

### Permission issues
If you see "Permission denied" errors:
```bash
sudo chown -R 1000:1000 state
```

### Certificate issues
- Ensure certificate files are readable
- Certificate CN or SAN must match DERP_HOSTNAME
- Use PEM format for certificates

## Security Considerations

- The container runs as non-root user (UID 1000)
- Mount certificates as read-only (`:ro`)
- Use a firewall to restrict access if needed
- Keep the image updated regularly

## License

MIT License - See LICENSE file for details

## Links

- [Tailscale Custom DERP Servers Documentation](https://tailscale.com/kb/1118/custom-derp-servers/)
- [Tailscale GitHub Repository](https://github.com/tailscale/tailscale)
```

