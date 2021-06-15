#!/bin/bash

function save_blob_as_image() {
    OUTPUT_DIR=$1
    # Remove first parameter
    shift
    # Get the rest of the parameters as an array
    ROW_ARR=("$@")

    Z=0
    X=${ROW_ARR[1]}
    Y=0

    if [ ${ROW_ARR[0]} -gt 0 ]; then
        Z=${ROW_ARR[0]}
        POW=${EXPONENTS[$Z]}
        Y=$(($POW - 1 - ${ROW_ARR[2]}))
    fi

    # Create output directory
    FULL_DIR_PATH="$OUTPUT_DIR/$Z/$X"
    mkdir -p $FULL_DIR_PATH

    BLOB=${ROW_ARR[3]}

    FILE_TYPE="jpg"
    if [[ $BLOB =~ ^89504E470D0A1A0A ]]; then
        FILE_TYPE="png"
    fi

    FILE_NAME="$FULL_DIR_PATH/$Y"
    FULL_FILE_NAME="$FILE_NAME.$FILE_TYPE"

    if [ -f $FULL_FILE_NAME ]; then
        exit
    fi

    # Write blob to file
    echo $BLOB | xxd -r -p - $FULL_FILE_NAME

    # Convert from jpg to png
    convert $FULL_FILE_NAME "$FILE_NAME.$OUTPUT_FILE_TYPE"
    # Remove non output type files
    if [ $FILE_TYPE != "$OUTPUT_FILE_TYPE" ]; then
        rm -f $FULL_FILE_NAME
    fi
}

GPKG=$GPKG_LOCATION
OUTPUT_DIR=$(realpath $OUTPUT_DIRECTORY)
GPKG_INFO_TABLE='gpkg_contents'
GPKG_CONTENT=$(sqlite3 $GPKG "select * from $GPKG_INFO_TABLE")
TMS="${TMS:-false}"
RUN_AS_JOB="${RUN_AS_JOB:-false}"

# Powers of 2 until 2^30
export EXPONENTS=(
    1
    2
    4
    8
    16
    32
    64
    128
    256
    512
    1024
    2048
    4096
    8192
    16384
    32768
    65536
    131072
    262144
    524288
    1048576
    2097152
    4194304
    8388608
    16777216
    33554432
    67108864
    134217728
    268435456
    536870912
    1073741824
)

# Make sure output file type is png or jpg
if [[ $OUTPUT_FILE_TYPE != "png" ]] && [[ $OUTPUT_FILE_TYPE != "jpg" ]]; then
    echo "Please enter a valid file type as env variable 'OUTPUT_FILE_TYPE', Valid file types are png / jpg"
    exit
fi

# Make sure env variable TMS values is true is false
if [[ $TMS != "true" ]] && [[ $TMS != "false" ]]; then
    echo "Please enter true / false for env variable 'TMS'"
    exit
fi

IFS='|' read -r -a GPKG_CONTENT_ARR <<<$GPKG_CONTENT
GPKG_TABLE_NAME=${GPKG_CONTENT_ARR[0]}

echo "Selected min zoom: $MIN_ZOOM"
echo "Selected max zoom: $MAX_ZOOM"
echo "Selected batch size: $BATCH_SIZE"

TILE_COUNT=$(sqlite3 $GPKG "select count(*) from (select * from $GPKG_TABLE_NAME where zoom_level between $MIN_ZOOM and $MAX_ZOOM)")

OFFSET=0
START_TIME="$(date -u +%s)"

# Get results from gpkg
BLOBS=($(sqlite3 $GPKG "select zoom_level, tile_column, tile_row, hex(tile_data) from $GPKG_TABLE_NAME where zoom_level between $MIN_ZOOM and $MAX_ZOOM limit $BATCH_SIZE offset $OFFSET")) # where zoom_level between $MIN_ZOOM and $MAX_ZOOM

# Get number of results
RESULTS_SIZE=${#BLOBS[@]}

# Loop as long as results are returned
while [ $RESULTS_SIZE -gt 0 ]; do
    for row in ${BLOBS[@]}; do
        # Split row columns
        IFS='|' read -r -a ROW_ARR <<<$row
        save_blob_as_image $OUTPUT_DIR "${ROW_ARR[@]}" &
        # if [ "$RUN_AS_JOB" = true ]; then
        #     echo true
        #     save_blob_as_image $OUTPUT_DIR "${ROW_ARR[@]}" &
        # else
        #     save_blob_as_image $OUTPUT_DIR "${ROW_ARR[@]}"
        # fi
    done

    END_TIME="$(date -u +%s)"
    ELAPSED="$(($END_TIME - $START_TIME))"
    echo "Total of $ELAPSED seconds elapsed for process"
    ((OFFSET += BATCH_SIZE))
    RESULTS_SIZE=${#BLOBS[@]}
    echo "Proccessed $(($BATCH_SIZE - ($BATCH_SIZE - $RESULTS_SIZE))) / $TILE_COUNT tiles"
    BLOBS=($(sqlite3 $GPKG "select zoom_level, tile_column, tile_row, hex(tile_data) from $GPKG_TABLE_NAME where zoom_level between $MIN_ZOOM and $MAX_ZOOM limit $BATCH_SIZE offset $OFFSET")) # where zoom_level between $MIN_ZOOM and $MAX_ZOOM
done

wait

END_TIME="$(date -u +%s)"
ELAPSED="$(($END_TIME - $START_TIME))"
echo "Total of $ELAPSED seconds elapsed for process"
