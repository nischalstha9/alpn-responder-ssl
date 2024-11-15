FROM ubuntu:24.04

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

RUN apt update
RUN apt install -y openssl \
    lsof \
    curl \
    bsdmainutils \
    nano
RUN DEBIAN_FRONTEND=noninteractive apt install -y python3

WORKDIR /opt/app

RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -subj /C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATIONAL_UNIT}/CN=${COMMON_NAME} -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem

COPY . .

HEALTHCHECK --interval=30s --timeout=5s --retries=5 --start-period=10s \
    CMD ["lsof", "-i:8000", "|", "grep", "-i", "':8000 (LISTEN)'"]
VOLUME /etc/nginx/certs
VOLUME /opt/app/domains.txt

EXPOSE 443

ENTRYPOINT [ "python3", "alpn-responder.py" ]
