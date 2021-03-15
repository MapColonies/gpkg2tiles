GPKG_FILE_LOCATION=""
OUTPUT_DIRECTORY=""

test -z $SETTINGS_FILE_LOCATION && echo "Please enter settings file location" && exit
test -z $GPKG_FILE_LOCATION && echo "Please enter geopackage location" && exit
test -z $OUTPUT_DIRECTORY && echo "Please enter output directory location" && exit

docker run --rm --name gpkg2tilesscript -it --entrypoint /bin/bash \
    -v $GPKG_FILE_LOCATION:/app/bluemar.gpkg \
    -v $OUTPUT_DIRECTORY:/app/output \
    -e OUTPUT_DIRECTORY=/app/output \
    -e GPKG_LOCATION=/app/bluemar.gpkg \
    gpkg2tilesscript
