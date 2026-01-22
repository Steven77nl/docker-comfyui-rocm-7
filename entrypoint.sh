#!/bin/bash

# Run this block only at first time a new image has been deployed

if [ -e "/firstrun" ]; then

  echo "First run already executed"

else

  echo "First run actions for new container"

  # force fetch latest ComfyUI
  cd /comfyui
  git pull origin master

  # restore models
  cp -aT /comfyui/models_repo /comfyui/models

  # check for comfyui-manager repo
  if [ -d "/comfyui/custom_nodes/comfyui-manager" ]; then

    # update if already exist
    cd /comfyui/custom_nodes/comfyui-manager
    git pull

  else

    # install if not exist
    cd /comfyui/custom_nodes
    git clone https://github.com/Comfy-Org/ComfyUI-Manager comfyui-manager

  fi

  cd /comfyui/custom_nodes/
  find . -type f -name 'requirements.txt' -exec pip install -r {} \;

  # Create firstrun file, so this block does not run again
  touch /firstrun


fi

find /comfyui/ -type d -exec chmod 2777 {} \;
find /comfyui/ -type f -exec chmod 777 {} \;

# Run ComfyUI
cd /comfyui
exec python3 main.py --lowvram --listen 0.0.0.0
