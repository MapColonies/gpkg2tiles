GPKG_FILE_LOCATION=""
OUTPUT_DIRECTORY=""
OUTPUT_FILE_TYPE="png"
TMS="true"
MIN_ZOOM=0
MAX_ZOOM=12

test -z $GPKG_FILE_LOCATION && echo "Please enter geopackage location" && exit
test -z $OUTPUT_DIRECTORY && echo "Please enter output directory location" && exit
# test [ $TMS != "true" ] && [ $TMS != "false" ] && echo "Please enter output directory location" && exit
#--cpus="6.0" \
docker run --rm --name gpkg2tilesscript \
    -v $GPKG_FILE_LOCATION:/app/bluemar.gpkg \
    -v $OUTPUT_DIRECTORY:/app/output \
    -e OUTPUT_DIRECTORY=/app/output \
    -e GPKG_LOCATION=/app/bluemar.gpkg \
    -e OUTPUT_FILE_TYPE=$OUTPUT_FILE_TYPE \
    -e TMS=$TMS \
    -e MIN_ZOOM=$MIN_ZOOM \
    -e MAX_ZOOM=$MAX_ZOOM \
    gpkg2tilesscript
