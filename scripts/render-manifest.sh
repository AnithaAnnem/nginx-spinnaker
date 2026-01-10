#!/bin/sh
set -e

ENV=$1

echo "Starting render step"
pwd
ls -la

echo "Reading values from parameter.yml"

APP_NAME=$(yq e '.app.name' parameter.yml)
IMAGE=$(yq e '.image.name' parameter.yml)
TAG=$(yq e '.image.tag' parameter.yml)
REPLICAS=$(yq e ".app.replicas.${ENV}" parameter.yml)

echo "APP_NAME=$APP_NAME"
echo "IMAGE=$IMAGE"
echo "TAG=$TAG"
echo "REPLICAS=$REPLICAS"

echo "Replacing placeholders in base and overlay manifests..."

find base overlay -type f -name "*.yaml" -exec sed -i \
  -e "s/APP_NAME/${APP_NAME}/g" \
  -e "s|IMAGE|${IMAGE}|g" \
  -e "s/TAG/${TAG}/g" \
  -e "s/REPLICAS/${REPLICAS}/g" {} +

echo "Render completed successfully"
exit 0
