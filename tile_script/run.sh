export LAYER_NAME=area3
export BUCKET=raster-tiles-dev
export GPKG_LOCATION="/home/shimon/Documents/gpkg2tiles/gpkg/$LAYER_NAME.gpkg"
export OUTPUT_DIRECTORY="/home/shimon/Documents/gpkg2tiles/script_output/$LAYER_NAME"
export OUTPUT_FILE_TYPE="png"
export TMS="true"
export MIN_ZOOM=18
export MAX_ZOOM=18
export BATCH_SIZE=1000
export RUN_AS_JOB=true

./gpkg2tiles.sh
