# gpkg2tiles

This is a utility that wraps `gdal2tiles.py` with an easier CLI menu and configurations provider.

## Installation & Usage

Build the docker by running `./docker_build.sh` script, then you can run the container by executing `./docker_run.sh` script.
This will run the container and open the CLI menu, where you can select / provide your desired configuration.

NOTE: make sure to run the container with a valid `volume` so there will be no problems finding the requested `gpkg` file.

## Configurations

There is a a `.settings` file in which you can configure whether you are working against an `S3` server or `FS`.

Besides `S3` settings, the CLI allows you to change default values for your current usage of the `gdal2tiles` utility, such as: resampling method, number of processes for the run, profile etc. You can choose to run the script in debug mode as well.

## Example

```
Enter geopackage location: /data/bluemarble.tif
Enter S3 key: bluemarble
Enter minimum zoom level (default: 0): 1
Enter maximum zoom level (default: 1): 1
Debugging? y/n (default: n): y
Enter number of processes (default: 1): 
Enter resampling method (default: bilinear): 
Is TMS compatible? (default: True): 
Enter profile (default: geodetic): 
```
