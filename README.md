#### Notes

> Port 443 should be available on host.

### Steps

#### Setup With Compose

> Put into `docker-compose.yml`

```yml
services:
  alpn:
    image: nischalstha/alpn-responder:main
    build:
      context: .
      dockerfile: Dockerfile
      target: alpn
    volumes:
      - ./certificates:/etc/nginx/certs
      - .:/opt/app
    ports:
      - 443:443
    env_file:
      - .env

```

- Run `docker compose up -d`

### Compose Less Setup

```sh
docker run -d \
  --name alpn \
  -p 443:443 \
  --env-file .env \
  -v ./certificates:/etc/nginx/certs \
  -v .:/opt/app \
  nischalstha/alpn-responder:main
```

#### Execution

- Run `docker compose exec dehydrated bash`
- Run if staging `STAGING_MODE=true ./entrypoint.sh` else `./entrypoint.sh`
- Run following:

```sh
    ./dehydrated --register --accept-terms
    ./dehydrated -c -f config
```

```sh
python3 main.py --staging -d alpn.shrestha-nischal.com.np
python3 main.py --config_file /opt/app/config --domains_file /opt/app/domains.txt
```
