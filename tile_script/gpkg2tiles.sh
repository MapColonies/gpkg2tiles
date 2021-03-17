#!/bin/bash
function save_blob_as_image() {
    OUTPUT_DIR=$1
    # echo $OUTPUT_DIR
    # Remove first parameter
    shift
    # Get the rest of the parameters as an array
    ROW_ARR=("$@")
    # echo ${ROW_ARR[@]}
    Z=0
    X=${ROW_ARR[1]}
    Y=0

    if [ ${ROW_ARR[0]} -gt 0 ]; then
        Z=${ROW_ARR[0]}
        POW=${EXPONENTS[$Z]}
        Y=$(($POW - 1 - ${ROW_ARR[2]}))
    fi
    # Z=${ROW_ARR[0]}
    # Z=$(($Z <= 1 ? 0 : ${ROW_ARR[0]} - 1))
    # X=${ROW_ARR[1]}
    # # Calculate number of tiles in zoom
    # # POW=$((2 << ($Z - 1)))
    # POW=${EXPONENTS[$Z]}
    # Y=$(($POW - 1 - ${ROW_ARR[2]}))
    # Create output directory
    mkdir -p "$OUTPUT_DIR/$Z/$X"
    # chmod -R 777 "$OUTPUT_DIR/$Z/$X"
    BLOB=${ROW_ARR[3]}
    # echo $BLOB
    FILE_TYPE="jpg"
    if [[ $BLOB =~ ^89504E470D0A1A0A ]]; then
        FILE_TYPE="png"
        # echo yes
    fi
    # echo $BLOB
    FILE_NAME="$OUTPUT_DIR/$Z/$X/$Y"
    FULL_FILE_NAME="$FILE_NAME.$FILE_TYPE"

    # echo $FILE_NAME
    # TODO: Check
    # echo $(sqlite3 geo.gpkg 'select hex(tile_data) from O_ihud_w84geo_Nov04_Apr20_gpkg_15_0 limit 1 offset 231246') | xxd -r -p - temp.png
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

if [[ $OUTPUT_FILE_TYPE != "png" ]] && [[ $OUTPUT_FILE_TYPE != "jpg" ]]; then
    echo "Please enter a valid file type as env variable 'OUTPUT_FILE_TYPE', Valid file types are png / jpg"
    exit
fi

if [[ $TMS != "true" ]] && [[ $TMS != "false" ]]; then
    echo "Please enter true / false for env variable 'TMS'"
    exit
fi

# echo $GPKG_CONTENT
IFS='|' read -r -a GPKG_CONTENT_ARR <<<$GPKG_CONTENT
GPKG_TABLE_NAME=${GPKG_CONTENT_ARR[0]}
# echo $GPKG_TABLE_NAME
echo $MIN_ZOOM
echo $MAX_ZOOM

OFFSET=0
BATCH_SIZE=1000
START_TIME="$(date -u +%s)"
# Create output directory
# mkdir -m 666 -p $OUTPUT_DIR
# chmod -R 666 $OUTPUT_DIR
# Get results from gpkg
BLOBS=($(sqlite3 $GPKG "select zoom_level, tile_column, tile_row, hex(tile_data) from $GPKG_TABLE_NAME where zoom_level between $MIN_ZOOM and $MAX_ZOOM limit $BATCH_SIZE offset $OFFSET")) # where zoom_level between $MIN_ZOOM and $MAX_ZOOM
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
        save_blob_as_image $OUTPUT_DIR "${ROW_ARR[@]}" #&
        # fi
        # echo $OUTPUT_DIR
        # echo $OUTPUT_DIR "${ROW_ARR[@]}"
    done
    END_TIME="$(date -u +%s)"
    ELAPSED="$(($END_TIME - $START_TIME))"
    echo "Total of $ELAPSED seconds elapsed for process"
    ((OFFSET += BATCH_SIZE))
    echo $OFFSET
    BLOBS=($(sqlite3 $GPKG "select zoom_level, tile_column, tile_row, hex(tile_data) from $GPKG_TABLE_NAME where zoom_level between $MIN_ZOOM and $MAX_ZOOM limit $BATCH_SIZE offset $OFFSET")) # where zoom_level between $MIN_ZOOM and $MAX_ZOOM
    RESULTS_SIZE=${#BLOBS[@]}
done
END_TIME="$(date -u +%s)"
ELAPSED="$(($END_TIME - $START_TIME))"
echo "Total of $ELAPSED seconds elapsed for process"
