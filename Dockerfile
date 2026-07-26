FROM jbarlow83/ocrmypdf:v17.8.1


ENV SCAN_SOURCE=/scans/sourcedir
ENV OCR_TARGET=/scans/targetdir
ENV BACKUP_DIR=/scans/backup
ENV TZ=Europe/Zurich
ENV DEBIAN_FRONTEND=noninteractive

COPY --chown=1000 scripts scripts/
USER root
RUN     apt-get update \
    &&  apt-get install -y \ 
    inotify-tools \
    tini \ 
    file \
    tzdata \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  chmod -R 750 scripts/

VOLUME ["$SCAN_SOURCE", "$OCR_TARGET", "$BACKUP_DIR"]    
USER app

ENTRYPOINT ["/usr/bin/tini", "--", "scripts/scan-index.sh"]

