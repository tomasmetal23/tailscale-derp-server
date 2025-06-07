# Derper Docker / Docker DERP Server

[English](#english) | [Español](#español)

---

## English

A multi-architecture Docker container for running a Tailscale DERP (Designated Encrypted Relay for Packets) server.

### What is DERP?

DERP is Tailscale's encrypted relay system that helps establish connections between devices when direct connectivity isn't possible due to restrictive NATs or firewalls. This container allows you to run your own custom DERP server.

### Features

- ✅ **Multi-architecture**: Supports `linux/amd64` and `linux/arm64`
- 🔒 **Secure**: Runs as non-root user
- 📦 **Lightweight**: Based on Alpine Linux
- 🚀 **Easy to use**: Simple configuration with environment variables

### Quick Start

#### Using Docker Run

```bash
docker run -d \
  --name derper \
  -p 8443:443 \
  -p 3478:3478/udp \
  -e DERP_DOMAIN=your-domain.com \
  -e DERP_ADDR=:8443 \
  -e DERP_CERTMODE=manual \
  -v /path/to/your/certificates:/app/certs \
  derper:latest
```

#### Using Docker Compose

```yaml
version: '3.8'

services:
  derper:
    image: derper:latest
    container_name: derper
    restart: unless-stopped
    ports:
      - "8443:443"
      - "3478:3478/udp"
    environment:
      - DERP_DOMAIN=your-domain.com
      - DERP_CERTMODE=manual
      - DERP_ADDR=:8443
      - DERP_STUN=true
    volumes:
      - ./certs:/app/certs:ro
    networks:
      - derp-network

networks:
  derp-network:
    driver: bridge
```

### Environment Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `DERP_DOMAIN` | DERP server domain | `localhost` |
| `DERP_ADDR` | Listen address and port | `:8443` |
| `DERP_STUN` | Enable STUN server | `true` |
| `DERP_CERTMODE` | Certificate mode (`letsencrypt`, `manual`) | `manual` |
| `DERP_CERTDIR` | Certificate directory | `/app/certs` |
| `DERP_HOSTNAME` | Server hostname | Derived from `DERP_DOMAIN` |
| `DERP_STUN_PORT` | STUN server port | `3478` |

### Certificate Configuration

#### Option 1: Manual Certificates

1. Place your certificates in a local directory:
   ```
   certs/
   ├── your-domain.com.crt
   └── your-domain.com.key
   ```

2. Mount the directory in the container:
   ```bash
   -v /path/to/certs:/app/certs:ro
   ```

#### Option 2: Let's Encrypt (Automatic)

```bash
docker run -d \
  --name derper \
  -p 8443:8443 \
  -p 80:80 \
  -p 3478:3478/udp \
  -e DERP_DOMAIN=your-domain.com \
  -e DERP_ADDR=:8443 \
  -e DERP_CERTMODE=letsencrypt \
  -v derper_certs:/app/certs \
  derper:latest
```

### Building

#### Simple Build

```bash
docker build -t derper:latest .
```

#### Multi-Architecture Build

```bash
# To push to a registry
docker buildx build --platform linux/amd64,linux/arm64 \
  -t your-registry/derper:latest --push .

# For a specific architecture
docker buildx build --platform linux/amd64 \
  -t derper:latest --load .
```

### Ports

- **8443/tcp**: HTTPS port for DERP server
- **3478/udp**: STUN port (if enabled)

### Tailscale Configuration

To use your custom DERP server, you need to configure Tailscale to use it:

1. Create an ACL configuration file in your Tailscale Admin Console
2. Add your custom DERP server:

```json
{
  "derpMap": {
    "regions": {
      "900": {
        "regionID": 900,
        "regionCode": "custom",
        "regionName": "Custom DERP",
        "nodes": [
          {
            "name": "custom-derp",
            "regionID": 900,
            "hostname": "your-domain.com",
            "ipv4": "YOUR.PUBLIC.IP.HERE",
            "stunPort": 3478,
            "stunOnly": false,
            "derpPort": 8443
          }
        ]
      }
    }
  }
}
```

### Logs and Monitoring

View container logs:
```bash
docker logs -f derper
```

Check server status:
```bash
curl -k https://your-domain.com:8443/derp/probe
```

### Security

- Container runs as non-root user (`derper:1001`)
- Valid TLS certificates are recommended
- Consider using a firewall to restrict access
- Keep the container updated regularly

### Troubleshooting

#### Container won't start
- Verify ports are not in use
- Ensure certificates are in the correct path
- Check logs with `docker logs derper`

#### Connectivity issues
- Verify ports 8443 and 3478 are open in your firewall
- Confirm DNS points correctly to your server
- Test connectivity with `telnet your-domain.com 8443`

#### SSL Certificates
- Ensure certificate files have correct permissions
- Verify certificate includes the correct domain
- For Let's Encrypt, ensure port 80 is available

---

## Español

Un contenedor Docker multi-arquitectura para ejecutar un servidor DERP (Designated Encrypted Relay for Packets) de Tailscale.

### ¿Qué es DERP?

DERP es el sistema de relay cifrado de Tailscale que ayuda a establecer conexiones entre dispositivos cuando la conectividad directa no es posible debido a NATs o firewalls restrictivos. Este contenedor te permite ejecutar tu propio servidor DERP personalizado.

### Características

- ✅ **Multi-arquitectura**: Soporta `linux/amd64` y `linux/arm64`
- 🔒 **Seguro**: Ejecuta como usuario no-root
- 📦 **Ligero**: Basado en Alpine Linux
- 🚀 **Fácil de usar**: Configuración simple con variables de entorno

### Inicio Rápido

#### Usando Docker Run

```bash
docker run -d \
  --name derper \
  -p 8443:8443 \
  -p 3478:3478/udp \
  -e DERP_DOMAIN=tu-dominio.com \
  -e DERP_ADDR=:8443 \
  -e DERP_CERTMODE=manual \
  -v /ruta/a/tus/certificados:/app/certs \
  derper:latest
```

#### Usando Docker Compose

```yaml
version: '3.8'

services:
  derper:
    image: derper:latest
    container_name: derper
    restart: unless-stopped
    ports:
      - "8443:8443"
      - "3478:3478/udp"
    environment:
      - DERP_DOMAIN=tu-dominio.com
      - DERP_CERTMODE=manual
      - DERP_ADDR=:8443
      - DERP_STUN=true
    volumes:
      - ./certs:/app/certs:ro
    networks:
      - derp-network

networks:
  derp-network:
    driver: bridge
```

### Variables de Entorno

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `DERP_DOMAIN` | Dominio del servidor DERP | `localhost` |
| `DERP_ADDR` | Dirección y puerto de escucha | `:8443` |
| `DERP_STUN` | Habilitar servidor STUN | `true` |
| `DERP_CERTMODE` | Modo de certificados (`letsencrypt`, `manual`) | `manual` |
| `DERP_CERTDIR` | Directorio de certificados | `/app/certs` |
| `DERP_HOSTNAME` | Hostname del servidor | Se deriva de `DERP_DOMAIN` |
| `DERP_STUN_PORT` | Puerto del servidor STUN | `3478` |

### Configuración de Certificados

#### Opción 1: Certificados Manuales

1. Coloca tus certificados en un directorio local:
   ```
   certs/
   ├── tu-dominio.com.crt
   └── tu-dominio.com.key
   ```

2. Monta el directorio en el contenedor:
   ```bash
   -v /ruta/a/certs:/app/certs:ro
   ```

#### Opción 2: Let's Encrypt (Automático)

```bash
docker run -d \
  --name derper \
  -p 8443:8443 \
  -p 80:80 \
  -p 3478:3478/udp \
  -e DERP_DOMAIN=tu-dominio.com \
  -e DERP_ADDR=:8443 \
  -e DERP_CERTMODE=letsencrypt \
  -v derper_certs:/app/certs \
  derper:latest
```

### Construcción

#### Construcción Simple

```bash
docker build -t derper:latest .
```

#### Construcción Multi-Arquitectura

```bash
# Para registrar en un registry
docker buildx build --platform linux/amd64,linux/arm64 \
  -t tu-registry/derper:latest --push .

# Para una arquitectura específica
docker buildx build --platform linux/amd64 \
  -t derper:latest --load .
```

### Puertos

- **8443/tcp**: Puerto HTTPS para el servidor DERP
- **3478/udp**: Puerto STUN (si está habilitado)

### Configuración en Tailscale

Para usar tu servidor DERP personalizado, necesitas configurar Tailscale para usarlo:

1. Crea un archivo de configuración ACL en tu Tailscale Admin Console
2. Agrega tu servidor DERP personalizado:

```json
{
  "derpMap": {
    "regions": {
      "900": {
        "regionID": 900,
        "regionCode": "custom",
        "regionName": "Custom DERP",
        "nodes": [
          {
            "name": "custom-derp",
            "regionID": 900,
            "hostname": "tu-dominio.com",
            "ipv4": "TU.IP.PUBLICA.AQUI",
            "stunPort": 3478,
            "stunOnly": false,
            "derpPort": 8443
          }
        ]
      }
    }
  }
}
```

### Logs y Monitoreo

Ver logs del contenedor:
```bash
docker logs -f derper
```

Verificar el estado del servidor:
```bash
curl -k https://tu-dominio.com:8443/derp/probe
```

### Seguridad

- El contenedor ejecuta como usuario no-root (`derper:1001`)
- Se recomienda usar certificados TLS válidos
- Considera usar un firewall para restringir el acceso
- Mantén el contenedor actualizado regularmente

### Troubleshooting

#### El contenedor no inicia
- Verifica que los puertos no estén en uso
- Asegúrate de que los certificados estén en la ruta correcta
- Revisa los logs con `docker logs derper`

#### Problemas de conectividad
- Verifica que los puertos 8443 y 3478 estén abiertos en tu firewall
- Confirma que el DNS apunte correctamente a tu servidor
- Prueba la conectividad con `telnet tu-dominio.com 8443`

#### Certificados SSL
- Asegúrate de que los archivos de certificado tengan los permisos correctos
- Verifica que el certificado incluya el dominio correcto
- Para Let's Encrypt, asegúrate de que el puerto 80 esté disponible

---

## Contributing / Contribuir

1. Fork the repository / Fork el repositorio
2. Create a feature branch / Crea una branch para tu feature (`git checkout -b feature/new-feature`)
3. Commit your changes / Commit tus cambios (`git commit -am 'Add new feature'`)
4. Push to the branch / Push a la branch (`git push origin feature/new-feature`)
5. Create a Pull Request / Crea un Pull Request

## License / Licencia

This project is licensed under the MIT License. See the `LICENSE` file for details.

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Useful Links / Enlaces Útiles

- [Official Tailscale DERP Documentation](https://tailscale.com/kb/1118/custom-derp-servers/)
- [Tailscale Repository](https://github.com/tailscale/tailscale)
- [Docker Hub](https://hub.docker.com/)

## Support / Soporte

If you encounter any issues or have questions, please open an issue in the GitHub repository.

Si encuentras algún problema o tienes alguna pregunta, por favor abre un issue en el repositorio de GitHub.