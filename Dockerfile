FROM osgeo/gdal:alpine-normal-3.2.0
RUN mkdir /app
WORKDIR /app
ENV PYTHONPATH=${PYTHONPATH}:'/app'
COPY . .
RUN chmod +x start.sh

RUN mkdir /vsis3 && chmod -R 777 /vsis3
CMD ["python3", "/app/main.py"]
