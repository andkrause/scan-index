FROM jbarlow83/ocrmypdf:v13.1.1


ENV SCAN_SOURCE=/scans/sourcedir
ENV OCR_TARGET=/scans/targetdir
ENV BACKUP_DIR=/scans/backup
ENV TZ=Europe/Zurich
ENV DEBIAN_FRONTEND=noninteractive

COPY --chown=root scripts scripts/

RUN     apt-get update \
    &&  apt-get install -y \ 
    inotify-tools \
    tini \ 
    file \
    tzdata \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  chmod -R 750 scripts/

VOLUME ["$SCAN_SOURCE", "$OCR_TARGET", "$BACKUP_DIR"]    


ENTRYPOINT ["/usr/bin/tini", "--", "scripts/scan-index.sh"]

