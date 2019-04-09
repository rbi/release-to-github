FROM debian:9

LABEL maintainer="Raik Bieniek <raik.bieniek@gmail.com>"
LABEL com.github.actions.name="Create Github Release"
LABEL com.github.actions.description="Allows to create releases on Github and upload binaries."
LABEL com.github.actions.icon="tag"
LABEL com.github.actions.color="orange"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends httpie && \
    rm -rf /var/lib/apt/lists/*

COPY "entrypoint.sh" /

ENTRYPOINT ["/entrypoint.sh"]
