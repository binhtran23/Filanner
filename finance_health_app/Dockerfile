FROM ghcr.io/cirruslabs/flutter:3.38.7 AS build

WORKDIR /app

COPY pubspec.yaml ./
RUN flutter clean || true
RUN flutter pub get --verbose

COPY . .

ARG API_BASE_URL=http://localhost:8000/api
ARG WS_URL=ws://localhost:8000/ws

RUN flutter config --enable-web
RUN flutter build web --release \
  --dart-define=API_BASE_URL=${API_BASE_URL} \
  --dart-define=WS_URL=${WS_URL}

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
