FROM ubuntu:20.04

ENV SCAN_SOURCE=/scans/sourcedir
ENV OCR_TARGET=/scans/targetdir
ENV BACKUP_DIR=/scans/backup
ENV TZ=Europe/Zurich
ENV DEBIAN_FRONTEND=noninteractive

COPY --chown=root scripts /scripts/
WORKDIR /

RUN     apt-get update \
    &&  apt-get install -y \ 
    inotify-tools \
    tini \ 
    file \
    tzdata \
    libqpdf-dev \
    zlib1g-dev \
    libjpeg-dev \
    libffi-dev \
    ghostscript \
    qpdf \
    tesseract-ocr \
    tesseract-ocr-deu \
    tesseract-ocr-eng \
    tesseract-ocr-fra \
    unpaper \
    python3-pip \
    python3-pil \
    python3-pytest \
    python3-reportlab \
    && pip3 install ocrmypdf \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  chmod -R 750 /scripts/

VOLUME ["$SCAN_SOURCE", "$OCR_TARGET", "$BACKUP_DIR"]    


ENTRYPOINT ["/usr/bin/tini", "--", "scripts/scan-index.sh"]

