#### Notes

> Port 443 should be available on host.

#### Example domains.txt file.

```txt
sespmission.moest.gov.np
```

### Steps

- Run `docker compose up -d`
- Run `docker compose exec dehydrated bash`
- Run if staging `STAGING_MODE=true ./entrypoint.sh` else `./entrypoint.sh`
- Run following:

```sh
    ./dehydrated --register --accept-terms
    ./dehydrated -c -f config
```

### Compose Less

```sh
docker run --name alpn -p 443:443 -v ./certificates:/etc/nginx/certs -v ./domains.txt:/opt/app/domains.txt nischalstha/alpn-responder:v1
```
