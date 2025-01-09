# Dehydrated-Wrapped

Dehydrated Wrapped is Dehydrated Wrapper that runs alpn server on background to respond to verification requests for Lets Encrypt. This project is wrapper for Dehydrated (https://github.com/lukas2511/dehydrated/). Dehydrated can be used to request certificates from Lets Encrypt using **TLS-ALPN-01**. Refer (https://letsencrypt.org/docs/challenge-types/) for challenge types.

**Objective** \
The deployment of certificates via tls-alpn-01 often involves complex configurations, including ALPN responders and fallback certificates. This wrapper simplifies the process, streamlining deployment. While future improvements may further simplify the workflow, this Docker image provides a convenient solution for now.

## Pros and Cons of TLS-ALPN-01

Pros:

- It works if port 80 is unavailable to you.
- It can be performed purely at the TLS layer.
- It can be used to validate IP Addresses as well.

Cons:

- It’s not supported by Apache, Nginx, or Certbot, and probably won’t be soon.
- Like HTTP-01, if you have multiple servers they need to all answer with the same content.
- This method cannot be used to validate wildcard domains.

## Usage

### Requirements

- Docker
- Port 443 should be available on host.

### Steps

#### 1. Setup

##### With Compose

Write into `docker-compose.yml` or `compose.yml`

```yml
services:
  alpn:
    image: nischalstha/dehydrated-wrapped:main
    build:
      context: .
      dockerfile: Dockerfile
      target: alpn
    volumes:
      - ./certificates:/etc/nginx/certs
    ports:
      - 443:443
    env_file:
      - .env
```

Then run:

```sh
$ docker compose up -d
```

##### Compose Less Setup

```sh
$ docker run --rm \
  --detach \
  --name alpn \
  --publish 443:443 \
  --volume ./certificates:/etc/nginx/certs \
  nischalstha/dehydrated-wrapped:main
```

##### 2. Execution

> [!IMPORTANT]
> `--staging` uses Let's Encrypt's staging server. Remove --staging flag for production certificates.

##### 2.1 Normal Execution

```sh
$ docker exec -t alpn dwrap --staging --domains s1.example.com,s2.example.com
```

##### 2.2 Execution with custom dehydrated config file / domains.txt file

> [!NOTE]
> Here `/opt/app/config` and `/opt/app/domains.txt` file is mounted via docker volume. \
> For `config` file, Refer:
>
> - https://raw.githubusercontent.com/nischalstha9/alpn-responder-ssl/main/config.example
> - https://raw.githubusercontent.com/lukas2511/dehydrated/master/docs/examples/config

```sh
$ docker run --rm \
  --detach \
  --name alpn \
  --publish 443:443 \
  --volume ./certificates:/etc/nginx/certs \
  --volume ./config:/opt/app/config \
  --volume ./domains.txt:/opt/app/domains.txt \
  nischalstha/dehydrated-wrapped:main

$ docker exec -t alpn dwrap --config-file /opt/app/config --domains-file /opt/app/domains.txt
```

##### 2.3 Execution of dehydrated raw

```sh
$ docker exec -t alpn dwrap dehyrated-raw <ANY DEHYDRATED OPTIONS>
```

#### Results

Your certificates can be found at certificates folder on execution directory. The certificates are protected with root permissions. Move them to preferred directory and use them in nginx config file.

```
.
└── certificates
    └── s1.example.com
        ├── cert-1736412857.csr
        ├── cert-1736412857.pem
        ├── cert-1736412914.csr
        ├── cert-1736412914.pem
        ├── cert.csr -> cert-1736412914.csr
        ├── cert.pem -> cert-1736412914.pem
        ├── chain-1736412914.pem
        ├── chain.pem -> chain-1736412914.pem
        ├── fullchain-1736412914.pem
        ├── fullchain.pem -> fullchain-1736412914.pem
        ├── privkey-1736412857.pem
        ├── privkey-1736412914.pem
        └── privkey.pem -> privkey-1736412914.pem

2 directories, 13 files
```

> [!TIP]
> Refer [nginx-Configuring HTTPS servers](https://nginx.org/en/docs/http/configuring_https_servers.html) for SSL configuration

### Configuration for running behind nginx proxy.

*If running behind nginx proxy, then the host side port should be changed as `80,443` can be occupied by nginx.*

On an nginx tcp load-balancer you can use the ssl_preread module to map a different port for acme-tls requests than for e.g. HTTP/2 or HTTP/1.1 requests.

Your config should look something like this:

Add following to /etc/nginx/nginx.conf

```conf
stream {
  map $ssl_preread_alpn_protocols $tls_port {
    ~\bacme-tls/1\b 10443;
    default 443;
  }

  server {
    listen 443;
    listen [::]:443;
    proxy_pass <localhost / IP of alpn responder/alpn-container>:<PORT>; #<------------ HERE
    ssl_preread on;
  }
}
```

Then run following command to reload nginx:

```sh
$ sudo nginx -t
$ sudo nginx -s reload
```

That way https requests are forwarded to port 443 on the backend server, and acme-tls/1 requests are forwarded to given port <PORT>.

## REFERENCE

- https://samdecrock.medium.com/deploying-lets-encrypt-certificates-using-tls-alpn-01-https-18b9b1e05edf
- https://github.com/dehydrated-io/dehydrated/blob/master/docs/tls-alpn.md
- https://github.com/dehydrated-io/dehydrated/
- https://letsencrypt.org/docs/challenge-types/
