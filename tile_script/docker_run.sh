docker run --rm --name gpkg2tilesscript -it --entrypoint /bin/bash \
    -v /home/shimon/Downloads/bluemar.gpkg:/app/bluemar.gpkg \
    -v /home/shimon/Documents/gpkg2tiles/script_output:/app/output \
    -e OUTPUT_DIRECTORY=/app/output \
    -e GPKG_LOCATION=/app/bluemar.gpkg \
    gpkg2tilesscript
