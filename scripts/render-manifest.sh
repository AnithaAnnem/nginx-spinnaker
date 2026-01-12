
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

ENV=$1
[ -z "$ENV" ] && echo "Usage: $0 <env>" && exit 1

echo "Reading parameter.yml"

APP_NAME=$(yq e '.app.name' parameter.yml)
IMAGE=$(yq e '.image.name' parameter.yml)
TAG=$(yq e '.image.tag' parameter.yml)
REPLICAS=$(yq e ".app.replicas.${ENV}" parameter.yml)
PORT=$(yq e '.port' parameter.yml)
CPU_REQUEST=$(yq e '.app.cpu.request' parameter.yml)
CPU_LIMIT=$(yq e '.app.cpu.limit' parameter.yml)
MEMORY_REQUEST=$(yq e '.app.memory.request' parameter.yml)
MEMORY_LIMIT=$(yq e '.app.memory.limit' parameter.yml)

cat base/service.yaml base/deployment.yaml \
| sed \
  -e "s/APP_NAME/${APP_NAME}/g" \
  -e "s|IMAGE|${IMAGE}|g" \
  -e "s/TAG/${TAG}/g" \
  -e "s/REPLICAS/${REPLICAS}/g" \
  -e "s/PORT/${PORT}/g" \
  -e "s/CPU_REQUEST/${CPU_REQUEST}/g" \
  -e "s/CPU_LIMIT/${CPU_LIMIT}/g" \
  -e "s/MEMORY_REQUEST/${MEMORY_REQUEST}/g" \
  -e "s/MEMORY_LIMIT/${MEMORY_LIMIT}/g" \
> final-manifest.yaml

echo "Final manifest generated"
cat final-manifest.yaml

