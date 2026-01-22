#!/bin/bash
set -e

export PATH="/app/ComfyUI_venv:$PATH"
id

if [ -e "/app/firstrun" ]; then
  echo "First run already executed"

else
  echo "First run actions for new container"

  # restore repo files
  cp -aT /app/ComfyUI/models_repo /app/ComfyUI/models
  cp -aT /app/ComfyUI/custom_nodes_repo /app/ComfyUI/custom_nodes
  cd /app/ComfyUI/custom_nodes/

  # check for ComfyUI-manager repo
  if [ ! -d "/app/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then

    # install if not exist
    wget https://github.com/Comfy-Org/ComfyUI-Manager/archive/refs/heads/main.zip
    unzip main.zip
    mv ComfyUI-Manager-main ComfyUI-Manager
    rm main.zip

  fi

  # install all requirements for the custom_nodes
  find . -type f -name 'requirements.txt' -print0 |
  while IFS= read -r -d '' f; do sed -e 's/\r$//' "$f"; printf '\n'; done |
  awk 'NF && $0 !~ /^[[:space:]]*#/' |
  sort -u > nodes_requirements.txt

  pip install -r test_requirements.txt

  # find . -type f -name 'requirements.txt' -exec pip install -r {} \;
  # Create firstrun file, so this block does not run again
  touch /app/firstrun

fi

rocminfo | grep -E "Name:|gfx|version|Version"
pip freeze

# Run ComfyUI
exec "$@"
