FROM andy008/ocrmypdf:latest

ENV SCAN_SOURCE=/scans/sourcedir
ENV OCR_TARGET=/scans/targetdir
ENV BACKUP_DIR=/scans/backup

COPY --chown=root scripts /scripts/
WORKDIR /
RUN     apt-get update \
    &&  apt-get install -y inotify-tools tini file \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  chmod -R 750 /scripts/

VOLUME ["$SCAN_SOURCE", "$OCR_TARGET", "$BACKUP_DIR"]    


ENTRYPOINT ["/usr/bin/tini", "--", "scripts/scan-index.sh"]


