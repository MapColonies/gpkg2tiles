GPKG_FILE_LOCATION="/home/shimon/Downloads/geo.gpkg"
OUTPUT_DIRECTORY="/home/shimon/Documents/gpkg2tiles/script_output"
OUTPUT_FILE_TYPE="png"
TMS="true"
MIN_ZOOM=0
MAX_ZOOM=12
BATCH_SIZE=1000
RUN_AS_JOB=true

test -z $GPKG_FILE_LOCATION && echo "Please enter geopackage location" && exit
test -z $OUTPUT_DIRECTORY && echo "Please enter output directory location" && exit

docker run --rm --name gpkg2tilesscript \
    -v $GPKG_FILE_LOCATION:/app/bluemar.gpkg \
    -v $OUTPUT_DIRECTORY:/app/output \
    -e OUTPUT_DIRECTORY=/app/output \
    -e GPKG_LOCATION=/app/bluemar.gpkg \
    -e OUTPUT_FILE_TYPE=$OUTPUT_FILE_TYPE \
    -e TMS=$TMS \
    -e MIN_ZOOM=$MIN_ZOOM \
    -e MAX_ZOOM=$MAX_ZOOM \
    -e BATCH_SIZE=$BATCH_SIZE \
    -e RUN_AS_JOB=$RUN_AS_JOB \
    gpkg2tilesscript
