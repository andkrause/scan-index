#!/bin/sh

LANGUAGES=${LANGUAGES:="deu+eng"}
OUTPUT_UID=${OUTPUT_UID:="$(id -u)"}
OUTPUT_GID=${OUTPUT_GID:="$(id -G $OUTPUT_UID)"}
OUTPUT_MASK=${OUTPUT_MASK:="777"}


get_directory_without_prefix() {
    file_directory=$1
    directory_prefix=$2

    directory_full=$(dirname "$file_directory")
    filename=$(basename "$file_directory")
    directory_no_prefix=${directory_full#"$directory_prefix"}

    #remove leading "/" if exists
    directory_no_prefix=${directory_no_prefix#/}
    echo "$directory_no_prefix"
}

ocr_pdf(){

    input_pdf=$1
    output_directory=$2
    output_filename=$3

    echo "Starting OCR for $input_pdf"
    mkdir -p "$output_directory" && chmod -R $OUTPUT_MASK "$output_directory" && chown -R $OUTPUT_UID:$OUTPUT_GID "$output_directory"

    ocrmypdf -l $LANGUAGES --quiet "$input_pdf" "$output_directory/$output_filename" 
    return_code=$?

    if [ $return_code -gt 0 ]; then
        cp "$input_pdf" "$output_directory/$output_filename"
        echo "OCR Error with file $input_pdf, copied pdf without ocr"
    else
        echo "OCR done. Output written to $output_directory/$output_filename"
    fi
   
    return $return_code
}

backup_file() {
    input_file=$1
    output_directory=$2
    output_filename=$3

    mkdir -p "$output_directory" && chmod -R $OUTPUT_MASK "$output_directory" && chown -R $OUTPUT_UID:$OUTPUT_GID "$output_directory"
    cp "$input_file" "$output_directory/$output_filename" 
    return_code=$?

    echo "Backed up $input_file to $output_directory/$output_filename"

    return $return_code
}

modify_permissions() {
    input_file="$1"

    chmod $OUTPUT_MASK "$input_file"
    chown $OUTPUT_UID:$OUTPUT_GID "$input_file"
}

process_file() {
    file=$1
    timestamp=$(date +%Y%m%d%H%M%S)

    if [ -f "$file" ]; then
        normalized_directory=$(get_directory_without_prefix "$file" $SCAN_SOURCE)
        filename=$(basename "$file")
        backup_file "$file" "$BACKUP_DIR/$normalized_directory" "${timestamp}_${filename}"
        # OCR onyl for PDF
        mimetype=$(file -b --mime-type "$file")
        if [ "$mimetype" = "application/pdf" ]; then
            ocr_filename="OCR_${timestamp}_${filename}"

            ocr_pdf "$file" "$OCR_TARGET/$normalized_directory" "$ocr_filename"
        
            if [ $? = 0 ]; then
                modify_permissions "$OCR_TARGET/$normalized_directory/$ocr_filename"
                backup_file "$OCR_TARGET/$normalized_directory/$ocr_filename" "$BACKUP_DIR/$normalized_directory" "$ocr_filename"
            fi

            rm "$file"

        else
            echo "File is not a pdf ($mimetype), no OCR..."
            mkdir -p "$OCR_TARGET/$normalized_directory" && chmod -R $OUTPUT_MASK "$OCR_TARGET/$normalized_directory" && chown -R $OUTPUT_UID:$OUTPUT_GID "$OCR_TARGET/$normalized_directory"
            mv "$file" "$OCR_TARGET/$normalized_directory/${timestamp}_${filename}"
            modify_permissions "$OCR_TARGET/$normalized_directory/${timestamp}_${filename}"
        fi
    else
        echo "$file does not exist, assuming this is a duplicate call"
    fi
}

find_pdf(){
    find $SCAN_SOURCE -type f | while read file; do 
        process_file "$file"
    done
}

wait_no_change() {
    
    file="$1"
    counter=0
    while [ "$last_change" != $(stat -c %Z "$file") ] && [ $counter -lt 11 ]; do
        last_change=$(stat -c %Z "$file")
        sleep 2
        counter=$counter+1
    done
}

# CLOSE_WRITE event is not fired when running in docker desktop on mac os
listen_pdf() {
    inotifywait -mrq -e CLOSE_WRITE --format "%w%f" $SCAN_SOURCE | while read file; do
        if [ -f "$file" ]; then
            wait_no_change "$file"
        fi
        process_file "$file"
    done
}



echo "Languages set to $LANGUAGES"

if [ -z $SCAN_SOURCE ]; then
    echo "Environment variable SCAN_SOURCE not set ..."
    exit 1
else 
    echo "SCAN_SOURCE set to: $SCAN_SOURCE"    
fi

if [ -z $OCR_TARGET ]; then
    echo "Environment variable OCR_TARGET not set ..."
    exit 1
else 

    echo "OCR_TARGET set to: $OCR_TARGET"    
fi

if [ -z $BACKUP_DIR ]; then
    echo "Environment variable BACKUP_DIR not set ..."
    exit 1
else 
    echo "BACKUP_DIR set to: $BACKUP_DIR"    
fi

echo "Output files will be owned by user: $OUTPUT_UID and group $OUTPUT_GID"
echo "Output files will have the permission $OUTPUT_MASK"

echo "Searching for exitsing files in $SCAN_SOURCE"

find_pdf

echo "Listening for changes in $SCAN_SOURCE"

listen_pdf