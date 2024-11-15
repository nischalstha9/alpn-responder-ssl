#### Notes

> Port 443 should be available on host.

#### Example domains.txt file.

```txt
sth-insecure.example.com
```

### Steps

#### Setup With Compose

> Put into `docker-compose.yml`

```yml
services:
  alpn:
    image: nischalstha/alpn-responder:main
    build: .
    volumes:
      - ./certificates:/etc/nginx/certs
      - ./domains.txt:/opt/app/domains.txt
    ports:
      - 443:443
```

- Run `docker compose up -d`

### Compose Less Setup

```sh
docker run --name alpn -p 443:443 -v ./certificates:/etc/nginx/certs -v ./domains.txt:/opt/app/domains.txt nischalstha/alpn-responder:main
```

#### Execution

- Run `docker compose exec dehydrated bash`
- Run if staging `STAGING_MODE=true ./entrypoint.sh` else `./entrypoint.sh`
- Run following:

```sh
    ./dehydrated --register --accept-terms
    ./dehydrated -c -f config
```
