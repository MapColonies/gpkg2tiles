FROM nouchka/sqlite3
RUN mkdir /app
WORKDIR /app
COPY . .

RUN apt-get update && apt-get install -y xxd imagemagick

RUN chmod +x gpkg2tiles.sh

ENTRYPOINT ["/app/gpkg2tiles.sh"]
