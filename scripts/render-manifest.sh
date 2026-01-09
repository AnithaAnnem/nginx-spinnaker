#!/bin/sh
set -e

echo "Starting render step"
pwd
ls -la

echo "Rendering kustomize output"
kustomize build overlay/dev > final-manifest.yaml

echo "Manifest rendered successfully"
ls -la final-manifest.yaml

exit 0
