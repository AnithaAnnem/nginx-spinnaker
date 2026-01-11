
# #!/bin/sh
# set -e

# ENV=$1

# echo "Starting render step"
# pwd
# ls -la

# echo "Reading values from parameter.yml"

# APP_NAME=$(yq e '.app.name' parameter.yml)
# IMAGE=$(yq e '.image.name' parameter.yml)
# TAG=$(yq e '.image.tag' parameter.yml)
# REPLICAS=$(yq e ".app.replicas.${ENV}" parameter.yml)

# echo "APP_NAME=$APP_NAME"
# echo "IMAGE=$IMAGE"
# echo "TAG=$TAG"
# echo "REPLICAS=$REPLICAS"

# echo "Replacing placeholders in base and overlay manifests..."

# find base overlay -type f -name "*.yaml" -exec sed -i \
#   -e "s/APP_NAME/${APP_NAME}/g" \
#   -e "s|IMAGE|${IMAGE}|g" \
#   -e "s/TAG/${TAG}/g" \
#   -e "s/REPLICAS/${REPLICAS}/g" {} +

# echo "Render completed successfully"
# exit 0





#!/bin/sh
set -e

# ============================
# Render Manifest Script
# Usage: ./render-manifest.sh <env>
# Example: ./render-manifest.sh dev
# ============================

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: $0 <env>"
  exit 1
fi

echo "Starting render step for environment: $ENV"
pwd
ls -la

echo "Reading values from parameter.yml"

APP_NAME=$(yq e '.app.name' parameter.yml)
IMAGE=$(yq e '.image.name' parameter.yml)
TAG=$(yq e '.image.tag' parameter.yml)
REPLICAS=$(yq e ".app.replicas.${ENV}" parameter.yml)
CPU_REQUEST=$(yq e '.app.cpu.request' parameter.yml)
CPU_LIMIT=$(yq e '.app.cpu.limit' parameter.yml)
MEMORY_REQUEST=$(yq e '.app.memory.request' parameter.yml)
MEMORY_LIMIT=$(yq e '.app.memory.limit' parameter.yml)
PORT=$(yq e '.port' parameter.yml)
READINESS_PROBE=$(yq e '.app.readinessProbe' parameter.yml)
LIVENESS_PROBE=$(yq e '.app.livenessProbe' parameter.yml)

echo "APP_NAME=$APP_NAME"
echo "IMAGE=$IMAGE"
echo "TAG=$TAG"
echo "REPLICAS=$REPLICAS"
echo "CPU_REQUEST=$CPU_REQUEST"
echo "CPU_LIMIT=$CPU_LIMIT"
echo "MEMORY_REQUEST=$MEMORY_REQUEST"
echo "MEMORY_LIMIT=$MEMORY_LIMIT"
echo "PORT=$PORT"
echo "READINESS_PROBE=$READINESS_PROBE"
echo "LIVENESS_PROBE=$LIVENESS_PROBE"

echo "Combining base and overlay manifests..."

# Create a temporary folder to store the combined template
TMP_TEMPLATE="/tmp/template.yaml"

cat base/service.yaml base/deployment.yaml > $TMP_TEMPLATE


echo "Replacing placeholders in combined template..."

# Replace all placeholders and write to final manifest
sed -e "s/APP_NAME/${APP_NAME}/g" \
    -e "s|IMAGE|${IMAGE}|g" \
    -e "s/TAG/${TAG}/g" \
    -e "s/REPLICAS/${REPLICAS}/g" \
    -e "s/CPU_REQUEST/${CPU_REQUEST}/g" \
    -e "s/CPU_LIMIT/${CPU_LIMIT}/g" \
    -e "s/MEMORY_REQUEST/${MEMORY_REQUEST}/g" \
    -e "s/MEMORY_LIMIT/${MEMORY_LIMIT}/g" \
    -e "s/PORT/${PORT}/g" \
    $TMP_TEMPLATE > final-manifest.yaml


echo "Render completed successfully"
echo "Manifest rendered successfully"
echo ""
echo "===== Final Manifest ====="
cat final-manifest.yaml

echo "===== SPINNAKER ARTIFACT ====="
cat final-manifest.yaml
