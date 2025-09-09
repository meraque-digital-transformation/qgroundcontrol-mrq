#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

DOCKERFILE_PATH="./deploy/docker/Dockerfile-build-android"
IMAGE_NAME="qgc-android-docker"
SOURCE_DIR="$(pwd)"
BUILD_DIR="${SOURCE_DIR}/build"
GSTREAMER_DIR=${SOURCE_DIR}/gstreamer-1.0-android-universal-1.18.6

installGstreamer() {
  wget https://gstreamer.freedesktop.org/data/pkg/android/1.18.6/gstreamer-1.0-android-universal-1.18.6.tar.xz
  mkdir -p $GSTREAMER_DIR
  tar xf gstreamer-1.0-android-universal-1.18.6.tar.xz -C $GSTREAMER_DIR
  rm gstreamer-1.0-android-universal-1.18.6.tar.xz
}

if [ -d "$GSTREAMER_DIR" ]; then
  echo "FOUND: GStreamer: $GSTREAMER_DIR"
  if [ -z "$(ls -A $GSTREAMER_DIR)" ]; then
    echo "NOT INSTALLED: GStreamer not installed in $GSTREAMER_DIR --> Installing GStreamer..."
    installGstreamer
  else
    echo "INSTALLED: GStreamer"
  fi
else
  echo "NOT FOUND: GStreamer --> Installing GStreamer in $GSTREAMER_DIR"
  installGstreamer
fi

# Build the Docker image for Android
docker build --file "${DOCKERFILE_PATH}" -t "${IMAGE_NAME}" "${SOURCE_DIR}"

# BUILD_DIR needs to exists to allow docker to bind-mount to it
if ! [ -d "$BUILD_DIR" ]; then
  mkdir $BUILD_DIR
fi

# Run the Docker container with adjusted mount points
docker run \
  --rm \
  --mount type=bind,src=${SOURCE_DIR},dst=/project/source \
  --mount type=bind,src=${BUILD_DIR},dst=/project/build \
  "${IMAGE_NAME}"
