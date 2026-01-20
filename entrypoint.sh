#!/bin/bash

# Run this block only at first time a new image has been deployed

if [ ! -e "/firstrun" ]; then

  # fetch latest ComfyUI
  git pull

  # check for comfyui-manager repo
  if [ -d "/comfyui/custom_nodes/comfyui-manager.git" ]; then

    # update if already exist
    cd /comfyui/custom_nodes/comfyui-manager
    git pull

  else

    # install if not exist
    cd /comfyui/custom_nodes
    git clone https://github.com/Comfy-Org/ComfyUI-Manager comfyui-manager

  fi

  # Create firstrun file, so this block does not run again
  touch /firstrun

else
  echo "First run already executed"
fi

# Run ComfyUI
cd /comfyui
exec python3 main.py --lowvram
