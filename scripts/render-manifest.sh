#!/bin/sh
set -e

ENV=$1

echo "Starting render step"
pwd
ls -la

APP_NAME=$(yq e '.appName' parameter.yml)
IMAGE=$(yq e '.image.repo' parameter.yml)
TAG=$(yq e '.image.tag' parameter.yml)
REPLICAS=$(yq e ".replicas.${ENV}" parameter.yml)

echo "APP_NAME=$APP_NAME"
echo "IMAGE=$IMAGE"
echo "TAG=$TAG"
echo "REPLICAS=$REPLICAS"

echo "Replacing placeholders..."

find base overlay -type f -name "*.yaml" -exec sed -i \
  -e "s/APP_NAME/${APP_NAME}/g" \
  -e "s|IMAGE|${IMAGE}|g" \
  -e "s/TAG/${TAG}/g" \
  -e "s/REPLICAS/${REPLICAS}/g" {} +

echo "Render completed successfully"
exit 0
