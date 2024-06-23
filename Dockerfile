FROM cirrusci/flutter:stable

WORKDIR /app

COPY . .

RUN flutter build web
