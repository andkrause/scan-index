# scan-index

## About

scan-index is based on [OCRmyPDF](https://ocrmypdf.readthedocs.io/en/latest/index.html). It provides the automation to watch a directory and do the following:

* create a backup of the raw pdf
* trigger OCR
* backup OCR result
* Original directory structire is preseved

When scan-index starts-up, it inspects the directory and kicks-off the ocr process.

As it is currently deployed to a Raspberry PI 4b. OCRmyPDF is installed via pip.

## Configuration

scan-index is configured through the following environment variables:

| Environment Variable | Default | Meaning | 
|----------------------|---------|---------|
| LANGUAGES |`deu+eng`| languages used for OCR (for details see OCRmyPDF documentation|
| OUTPUT_UID |`id -u` | UID of the owner set on all output scans. This defaults to the user executing the script |
| OUTPUT_GID |`id -G $OUTPUT_UID`| Group ID set on all output scans. This defaults to the one of the user executing the script |
| OUTPUT_MASK | `777`| Permissions of the outut files (Target and Backup) |
| SCAN_SOURCE| `/scans/sourcedir`| Root directory where scans will be searched |
| OCR_TARGET| `/scans/targetdir` | Directory where OCR result will be placed |
| BACKUP_DIR| `/scans/backup` | Directory where OCR Result and input file wille be backed up| 

## Running the image

As the image comes with sensible defaults you can just execute `docker run -d --name scan-index andy008/scan-index:latest`

However it is highly recommended to customize the volumes backing SCAN_SOURCE, OCR_TARGET and BACKUP_DIR.

```
docker run --name scan-index \
-v /my/own/scans:/scans/sourcedir \
-v /my/own/target:/scans/targetdir \
-v /my/own/backup:/scans/backup \
andy008/scan-index:latest
```