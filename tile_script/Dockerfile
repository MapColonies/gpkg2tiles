FROM nouchka/sqlite3
RUN mkdir /app
WORKDIR /app

RUN apt-get update && apt-get install -y xxd imagemagick s3cmd

COPY .s3cfg /root/.s3cfg
COPY . .

RUN chmod +x gpkg2tiles.sh

ENTRYPOINT ["/app/gpkg2tiles.sh"]
