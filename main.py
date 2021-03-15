import subprocess
import load_configurations
from os import path

MIN_ZOOM_LEVEL = "0"
MAX_ZOOM_LEVEL = "1"
PROFILE = "geodetic"
RESAMPLING = "bilinear"
TMSCOMPATIBLE = True
DEBUGGING_TRUE = "y"
DEBUGGING_FALSE = "n"
PROCESSES = 1

gpkg_location = input("Enter geopackage location: ")
tiles_location = input("Enter output location: ")
min_zoom_level = input("Enter minimum zoom level (default: %s): " % MIN_ZOOM_LEVEL) or MIN_ZOOM_LEVEL
max_zoom_level = input("Enter maximum zoom level (default: %s): " % MAX_ZOOM_LEVEL) or MAX_ZOOM_LEVEL
debug = input("Debugging? y/n (default: %s): " % DEBUGGING_FALSE) or DEBUGGING_FALSE
processes = input("Enter number of processes (default: %s): " % PROCESSES) or PROCESSES
resampling = input("Enter resampling method (default: %s): " % RESAMPLING) or RESAMPLING
tms_compatible = input("Is TMS compatible? (default: %s): " % TMSCOMPATIBLE) or TMSCOMPATIBLE
profile = input("Enter profile (default: %s): " % PROFILE) or PROFILE

if not gpkg_location or not path.exists(gpkg_location):
    print("Invalid geopackage location.")

elif not tiles_location:
    print("Invalid output location.")

else:
    if not load_configurations.is_fs:
        tiles_location = '/vsis3/{0}/{1}'.format(load_configurations.bucket, tiles_location)

    tms_compatible = "--tmscompatible" if tms_compatible else ""
    debug = debug.lower()
    verbose = "--verbose" if debug == DEBUGGING_TRUE else ""

    for zoom_level in range(int(min_zoom_level), int(max_zoom_level)+1):
        script = 'gdal2tiles.py {0} -e -p {1} -r bilinear -z {2} {3} {4} {5} --processes {6} {7}'.format(load_configurations.aws_config, profile,
                                                                                     zoom_level, tms_compatible, gpkg_location, tiles_location, 
                                                                                     processes, verbose)
        p = subprocess.Popen(script, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        if debug == DEBUGGING_TRUE:
            print(script)
            for line in p.stdout.readlines():
                print(line)
        
        retval = p.wait()
        if debug == DEBUGGING_TRUE:
            print("return status code: %s" % retval)

        print("Done zoom level %s" % zoom_level)
