FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    ca-certificates \
    libcurl4 \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY interactive-server.sh /interactive-server.sh
COPY run-server.sh /run-server.sh
RUN chmod +x /entrypoint.sh /interactive-server.sh /run-server.sh

WORKDIR /data
EXPOSE 19132/udp

ENTRYPOINT ["/entrypoint.sh"]