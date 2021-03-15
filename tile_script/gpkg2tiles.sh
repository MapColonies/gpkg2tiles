#!/bin/bash

function save_blob_as_image() {
    OUTPUT_DIR=$1
    # echo $OUTPUT_DIR
    # Remove first parameter
    shift
    # Get the rest of the parameters as an array
    ROW_ARR=("$@")
    # echo ${ROW_ARR[@]}
    Z=${ROW_ARR[0]}
    X=${ROW_ARR[2]}
    Y=${ROW_ARR[1]}

    # Create output directory
    mkdir -p "$OUTPUT_DIR/$Z/$X"
    chmod -R 666 "$OUTPUT_DIR/$Z/$X"

    BLOB=${ROW_ARR[3]}
    # echo $BLOB
    FILE_TYPE="jpg"

    if [[ $BLOB =~ ^89504E470D0A1A0A ]]; then
        FILE_TYPE="png"
        # echo yes
    fi
    # echo $BLOB

    FILE_NAME="$OUTPUT_DIR/$Z/$X/$Y.$FILE_TYPE"
    # echo $FILE_NAME

    # TODO: Check
    # echo $(sqlite3 geo.gpkg 'select hex(tile_data) from O_ihud_w84geo_Nov04_Apr20_gpkg_15_0 limit 1 offset 231246') | xxd -r -p - temp.png

    # Write blob to file
    echo $BLOB | xxd -r -p - $FILE_NAME
}

GPKG=$GPKG_LOCATION
OUTPUT_DIR=$(realpath $OUTPUT_DIRECTORY)

GPKG_INFO_TABLE='gpkg_contents'
GPKG_CONTENT=$(sqlite3 $GPKG "select * from $GPKG_INFO_TABLE")
# echo $GPKG_CONTENT
IFS='|' read -r -a GPKG_CONTENT_ARR <<<$GPKG_CONTENT
GPKG_TABLE_NAME=${GPKG_CONTENT_ARR[0]}
# echo $GPKG_TABLE_NAME

OFFSET=0
BATCH_SIZE=1000

START_TIME="$(date -u +%s)"

# Create output directory
# mkdir -m 666 -p $OUTPUT_DIR
# chmod -R 666 $OUTPUT_DIR

# Get results from gpkg
BLOBS=($(sqlite3 $GPKG "select zoom_level, tile_column, tile_row, hex(tile_data) from $GPKG_TABLE_NAME limit $BATCH_SIZE offset $OFFSET"))
# BLOBS=($(sqlite3 -batch $GPKG "select writefile('$OUTPUT_DIR' || '/' || zoom_level || '/' || tile_row || '/' || tile_column || '.png', tile_data) from $GPKG_TABLE_NAME limit 10 offset $OFFSET"))
# exit

# Get number of results
RESULTS_SIZE=${#BLOBS[@]}

# Loop as long as results are returned
while [ $RESULTS_SIZE -gt 0 ]; do
    # echo $RESULTS_SIZE
    # n=0
    for row in ${BLOBS[@]}; do
        # Split row columns
        IFS='|' read -r -a ROW_ARR <<<$row

        # echo ${#ROW_ARR}
        # echo $OUTPUT_DIR "${ROW_ARR[@]}"

        # Check if row size is greater than 1
        # if [ ${#ROW_ARR} -eq 5 ]; then
        # echo $OUTPUT_DIR
        # echo $OUTPUT_DIR "${ROW_ARR[@]}"
        save_blob_as_image $OUTPUT_DIR "${ROW_ARR[@]}"
        # fi

        # echo $OUTPUT_DIR
        # echo $OUTPUT_DIR "${ROW_ARR[@]}"
    done
    ((OFFSET += BATCH_SIZE))
    echo $OFFSET

    BLOBS=($(sqlite3 $GPKG "select zoom_level, tile_column, tile_row, hex(tile_data) from $GPKG_TABLE_NAME limit $BATCH_SIZE offset $OFFSET"))
    RESULTS_SIZE=${#BLOBS[@]}
done

END_TIME="$(date -u +%s)"

ELAPSED="$(($END_TIME - $START_TIME))"
echo "Total of $ELAPSED seconds elapsed for process"
