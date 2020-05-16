#!/bin/sh

inotifywait -mrq -e create --format %w%f /media/storage/scans | while read folder file
do
    echo "Die Datei $file wurde gerade in $folder erstellt."
done