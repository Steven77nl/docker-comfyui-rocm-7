#!/usr/bin/env bash
set -e
id

export PATH="/opt/venv/bin:$PATH"

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

  # cleaning file (set all to allow update, and old packages)
  sed -i 's/==/>=/g' nodes_requirements.txt
  sed -i '/tensorflow-addons/d' nodes_requirements.txt

  pip install -r nodes_requirements.txt

  # find . -type f -name 'requirements.txt' -exec pip install -r {} \;
  # Create firstrun file, so this block does not run again
  touch /app/firstrun

fi

pip freeze
rocminfo | grep -E "Name:|gfx|version|Version"
clinfo | grep -i version

# Run ComfyUI
cd /app/ComfyUI/
exec "$@"
