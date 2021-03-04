import configparser

FILE_NAME = '.settings'
config = configparser.ConfigParser()
config.read(FILE_NAME)

is_fs = False if config['STORAGE_PROVIDER']['FS'] == 'FALSE' else True
aws_config = ""

if not is_fs:
    bucket = config['AWS']['bucket']

    if config['AWS']['SecretAccessKey']:
        aws_config += "--config AWS_SECRET_ACCESS_KEY {0} ".format(config['AWS']['SecretAccessKey'])

    if config['AWS']['AccessKeyId']:
        aws_config += "--config AWS_ACCESS_KEY_ID {0} ".format(config['AWS']['AccessKeyId'])

    if config['AWS']['Endpoint']:
        aws_config += "--config AWS_S3_ENDPOINT {0} ".format(config['AWS']['Endpoint'])

    if config['AWS']['Https']:
        aws_config += "--config AWS_HTTPS {0} ".format(config['AWS']['Https'])

    if config['AWS']['VirtualHosting']:
        aws_config += "--config AWS_VIRTUAL_HOSTING {0} ".format(config['AWS']['VirtualHosting'])
