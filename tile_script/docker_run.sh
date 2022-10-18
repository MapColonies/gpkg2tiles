LAYER_NAME=Tzor
BUCKET=""
GPKG_FILE_LOCATION="/home/shimon/Downloads/gpkgs/$LAYER_NAME.gpkg"
OUTPUT_DIRECTORY="/home/shimon/Documents/GpkgMerger/output/$LAYER_NAME" #"/home/shimon/Documents/gpkg2tiles/script_output/stam"
OUTPUT_FILE_TYPE="png"
TMS="true"
MIN_ZOOM=1
MAX_ZOOM=19
BATCH_SIZE=1000
RUN_AS_JOB=true

test -z $GPKG_FILE_LOCATION && echo "Please enter geopackage location" && exit
test -z $OUTPUT_DIRECTORY && echo "Please enter output directory location" && exit

docker run --rm -d -it --network host --name gpkg2tilesscript-$LAYER_NAME-$MIN_ZOOM-$MAX_ZOOM \
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
    -e LAYER_NAME=$LAYER_NAME \
    -e BUCKET=$BUCKET \
    gpkg2tilesscript
