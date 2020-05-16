FROM andy008/ocrmypdf:ubuntu

COPY --chown=root scan-index.sh 

RUN     apt-get update \
    &&  apt-get install -y inotify-tools tini \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  chmod 750 scan-index.sh

ENTRYPOINT ["./scan-index.sh"]
