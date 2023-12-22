buildah rmi effiana/nginx:latest
# Set your manifest name
export MANIFEST_NAME="nginx"

# Set the required variables
export BUILD_PATH="nginx"
export USER="effiana"
export IMAGE_NAME="nginx"
export IMAGE_TAG="latest"

# Create a multi-architecture manifest
buildah manifest create ${MANIFEST_NAME}

# Build your amd64 architecture container
buildah bud \
    --format=oci \
    --compress \
    --tag "${USER}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --manifest ${MANIFEST_NAME} \
    --arch amd64 \
    -f ./${BUILD_PATH}/Dockerfile .

# Build your arm64 architecture container
buildah bud \
    --format=oci \
    --compress \
    --tag "${USER}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --manifest ${MANIFEST_NAME} \
    --arch arm64 \
    -f ./${BUILD_PATH}/Dockerfile .

# Push the full manifest, with both CPU Architectures
buildah manifest push --all \
    ${MANIFEST_NAME} \
    "docker://${USER}/${IMAGE_NAME}:${IMAGE_TAG}"