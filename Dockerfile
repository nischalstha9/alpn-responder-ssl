# Copyright (c) Humanitarian OpenStreetMap Team
# This file is part of Dehydrated-Wrapped.
#
#     Dehydrated-Wrapped can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     Dehydrated-Wrapped is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with Dehydrated-Wrapped.  If not, see <https:#www.gnu.org/licenses/>.
#

FROM ubuntu:24.04 as temp_cert_gen

ENV PYTHONUNBUFFERED=1
ENV COUNTRY=NP
ENV STATE=BAGMATI
ENV LOCALITY=KATHMANDU
ENV ORGANIZATION=ORG
ENV ORGANIZATIONAL_UNIT=DevOps
ENV COMMON_NAME=*.example.com
ENV EMAIL=developer@example.com

RUN mkdir -p /etc/ssl/

RUN apt update && apt install -y openssl \
    lsof \
    curl \
    bsdmainutils \
    nano

RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -subj /C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATIONAL_UNIT}/CN=${COMMON_NAME} -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem

FROM ubuntu:24.04 as alpn

ENV PYTHONUNBUFFERED=1

RUN mkdir -p /opt/app \
    /etc/nginx/certs \
    /etc/dehydrated/alpn-certs \
    /var/www/dehydrated \
    /etc/ssl \
    /log

WORKDIR /opt/app

RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y python3 \
    curl \
    bsdmainutils

COPY --from=temp_cert_gen /etc/ssl/ /etc/ssl/

COPY . .

COPY ./dwrap /usr/bin/dwrap

HEALTHCHECK --interval=30s --timeout=5s --retries=5 --start-period=10s \
    CMD ["lsof", "-i:443", "|", "grep", "-i", "':443 (LISTEN)'"]

VOLUME /etc/nginx/certs

EXPOSE 443

ENTRYPOINT [ "/usr/bin/dwrap", "alpn-server" ]