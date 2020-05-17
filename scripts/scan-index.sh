#!/bin/sh

LANGUAGES=${LANGUAGES:="deu+eng"}


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
    mkdir -p "$output_directory"

    ocrmypdf -l $LANGUAGES --quiet --jobs 1 "$input_pdf" "$output_directory/$output_filename" 
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

    mkdir -p "$output_directory"

    cp "$input_file" "$output_directory/$output_filename" 
    return_code=$?

    echo "Backed up $input_file to $output_directory/$output_filename"

    return $return_code
}

process_file() {
    file=$1
    timestamp=$(date +%Y%m%d%H%M%S)

    if [ -f "$file" ]; then
        normalized_directory=$(get_directory_without_prefix $file $SCAN_SOURCE)
        filename=$(basename $file)
        echo "Timestamp: $timestamp"
        backup_file $file "$BACKUP_DIR/$normalized_directory" "${timestamp}_${filename}"

        ocr_filename="OCR_${timestamp}_${filename}"

        ocr_pdf $file "$OCR_TARGET/$normalized_directory" $ocr_filename
        
        if [ $? = 0 ]; then
            echo "Success"
            backup_file "$OCR_TARGET/$normalized_directory/OCR_$filename" "$BACKUP_DIR/$normalized_directory" $ocr_filename
        fi

        rm $file

    else
        echo "$file does not exist, assuming this is a duplicate call"
    fi
}

find_pdf(){
    find $SCAN_SOURCE -type f -iname '*.pdf' | while read file; do 
        process_file $file
    done
}

listen_pdf() {
    inotifywait -mrq -e create --format "%w%f" $SCAN_SOURCE | while read file; do
         process_file $file
    done
}

echo "Languages set to $LANGUAGES"

echo "Searching for exitsing files in $SCAN_SOURCE"

find_pdf

echo "Listening for changes in $SCAN_SOURCE"

listen_pdf