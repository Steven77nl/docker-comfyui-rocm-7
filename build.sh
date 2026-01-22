# Get host user id and group id
export USER_UID=$(id -u)
export USER_GID=$(id -g)

# building with the following ID's
echo
echo "USER AND GROUP ID"
echo "-------------------"
echo "USER_UID=$USER_UID"
echo "USER_GID=$USER_GID"
echo

# build docker with correct user and group id's
docker build \
  --build-arg HOST_USER_UID=$USER_UID \
  --build-arg HOST_USER_GID=$USER_GID \
  --tag comfyui-rocm-7.2 .

  #--no-cache \
