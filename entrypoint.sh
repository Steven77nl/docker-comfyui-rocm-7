#!/usr/bin/env bash
set -e
id

export PATH="/opt/venv/bin:$PATH"

if [ -e "/app/firstrun" ]; then

  echo "First run already executed"

else

  echo "*****************************************************"
  echo "      First run actions for a fresh container "
  echo "   Run time depends on the amount of custom nodes"
  echo "*****************************************************"

  # restore repo files
  cp -aT /app/ComfyUI/models_repo /app/ComfyUI/models
  cp -aT /app/ComfyUI/custom_nodes_repo /app/ComfyUI/custom_nodes
  cd /app/ComfyUI/custom_nodes/

  # check for ComfyUI-manager repo
  if [ ! -d "/app/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then

    # install if not exist
    git clone https://github.com/Comfy-Org/ComfyUI-Manager

  fi

  # install all requirements for the custom_nodes
  find . -type f -name 'requirements.txt' -print0 |
  while IFS= read -r -d '' f; do sed -e 's/\r$//' "$f"; printf '\n'; done |
  awk 'NF && $0 !~ /^[[:space:]]*#/' |
  sort -u > nodes_requirements.txt

  # fixed for older custom nodes
  sed -i 's/==/>=/g' nodes_requirements.txt
  sed -i '/tensorflow-addons/d' nodes_requirements.txt

  # install improved nodes_requirements.txt
  pip install -r nodes_requirements.txt --no-cache-dir

  # mark container first run as finished
  touch /app/firstrun

fi

pip freeze
rocminfo | grep -E "Name:|gfx|version|Version"
clinfo | grep -i version

# Run ComfyUI
cd /app/ComfyUI/
exec "$@"
