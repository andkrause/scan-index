#!/bin/sh

LANGUAGES="eng+deu"

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



find_pdf(){
    find $SCAN_SOURCE -type f -iname '*.pdf' | while read file; do 
        normalized_directory=$(get_directory_without_prefix $file $SCAN_SOURCE)
        filename=$(basename $file)
        ocr_pdf $file "$OCR_TARGET/$normalized_directory" "OCR_$filename"
    done
}

listen_pdf() {
    inotifywait -mrq -e create --format "%w%f" $SCAN_SOURCE | while read file; do
        normalized_directory=$(get_directory_without_prefix $file $SCAN_SOURCE)
        filename=$(basename $file)
        ocr_pdf $file "$OCR_TARGET/$normalized_directory" "OCR_$filename"
    done
}

echo "Searching for exitsing files in $SCAN_SOURCE"

find_pdf

echo "Listening for changes in $SCAN_SOURCE"

listen_pdf