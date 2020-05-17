FROM andy008/ocrmypdf

ENV SCAN_SOURCE=/scans/sourcedir
ENV OCR_TARGET=/scans/targetdir

#COPY --chown=root scripts .
WORKDIR /
RUN     apt-get update \
    &&  apt-get install -y inotify-tools tini \
    &&  rm -rf /var/lib/apt/lists/* 
#    &&  chmod -r 750 scripts

ENTRYPOINT [""]
#ENTRYPOINT ["/usr/bin/tini", "--", "./scan-index.sh"]

# docker run -it -v $(pwd)/scripts:/scripts -v $(pwd)/data/sourcedir:/scans/sourcedir -v $(pwd)/data/targetdir:/scans/targetdir --rm --name scan-index andy008/scan-index:latest /bin/sh