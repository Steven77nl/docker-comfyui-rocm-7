# Get host user id and group id
export USER_UID=$(id -u)
export USER_GID=$(id -g)

# Get host video and render groups
export RENDER_GID=$(stat -c '%g' /dev/dri/renderD128 2>/dev/null || stat -c '%g' /dev/dri/renderD129)
export VIDEO_GID=$(stat -c '%g' /dev/dri/card0 2>/dev/null || echo 44)

echo "USER_UID=$USER_UID USER_GID=$USER_GID  RENDER_GID=$RENDER_GID  VIDEO_GID=$VIDEO_GID"

# build docker with correct user and group id's
docker build \
  --build-arg HOST_USER_UID=$USER_UID \
  --build-arg HOST_USER_GID=$USER_GID \
  --build-arg HOST_VIDEO_GID=$VIDEO_GID \
  --build-arg HOST_RENDER_GID=$RENDER_GID \
  --tag comfyui-rocm-7.1.1 .

  #--no-cache \
