#!/bin/sh
set -e

ENV=${parameters.env}

echo "Environment: $ENV"
ls -la

APP_NAME=$(yq e '.app.name' parameter.yml)
REPLICAS=$(yq e ".app.replicas.${ENV}" parameter.yml)
IMAGE=$(yq e '.image.name' parameter.yml)
TAG=$(yq e '.image.tag' parameter.yml)

sed -i \
  -e "s/APP_NAME/${APP_NAME}/g" \
  -e "s/REPLICAS/${REPLICAS}/g" \
  -e "s/IMAGE/${IMAGE}/g" \
  -e "s/TAG/${TAG}/g" \
  base/deployment.yaml base/service.yaml

kustomize build overlay/${ENV} > final-manifest.yaml

echo "Final manifest created"
cat final-manifest.yaml
