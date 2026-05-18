FROM dart:3.4-sdk AS base

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN git clone --depth 1 --branch 3.41.9 https://github.com/flutter/flutter.git $FLUTTER_HOME \
    && flutter config --no-analytics \
    && flutter precache --web \
    && flutter doctor

WORKDIR /app

COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get || true
