FROM ubuntu:24.04 as base

ENV COUNTRY=NP
ENV STATE=BAGMATI
ENV LOCALITY=KATHMANDU
ENV ORGANIZATION=ORG
ENV ORGANIZATIONAL_UNIT=DevOps
ENV COMMON_NAME=*.example.com
ENV EMAIL=developer@example.com

RUN mkdir -p /opt/app
RUN mkdir -p /etc/nginx/certs
RUN mkdir -p /etc/dehydrated/alpn-certs
RUN mkdir -p /var/www/dehydrated
RUN mkdir -p /log

RUN apt update


FROM base as snakeoil_cert_gen
RUN apt install -y openssl \
    lsof \
    curl \
    bsdmainutils \
    nano

RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -subj /C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATIONAL_UNIT}/CN=${COMMON_NAME} -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem

FROM base as alpn

RUN mkdir -p /etc/ssl/

WORKDIR /opt/app

RUN DEBIAN_FRONTEND=noninteractive apt install -y python3 \
    curl \
    bsdmainutils

COPY --from=snakeoil_cert_gen /etc/ssl/ /etc/ssl/

COPY . .

HEALTHCHECK --interval=30s --timeout=5s --retries=5 --start-period=10s \
    CMD ["lsof", "-i:8000", "|", "grep", "-i", "':8000 (LISTEN)'"]

VOLUME /etc/nginx/certs

EXPOSE 443

FROM alpn as runtime
ENV PYTHONUNBUFFERED=1
ENTRYPOINT [ "python3", "main.py", "alpn-server" ]
