#!/usr/bin/env bash
set -e
id

source /opt/venv/bin/activate

if [ -e "/app/firstrun" ]; then

  echo
  echo "*****************************************************"
  echo "      Skipping Initial setup "
  echo "*****************************************************"
  echo

else

  echo
  echo "*****************************************************"
  echo "      Firstrun actions for a fresh container "
  echo "*****************************************************"
  echo

  # restore repo files
  cp -aT /app/ComfyUI/models_repo /app/ComfyUI/models
  cp -aT /app/ComfyUI/custom_nodes_repo /app/ComfyUI/custom_nodes
  cd /app/ComfyUI/custom_nodes/

  # check for ComfyUI-manager repo
  if [ ! -d "/app/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then
    # install if not exist
    git clone https://github.com/Comfy-Org/ComfyUI-Manager
  fi

  # mark container first run as finished
  touch /app/firstrun

fi

current_nodes_count=$(find /app/ComfyUI/custom_nodes/ -mindepth 1 -maxdepth 1 -type d | wc -l)
previous_nodes_count=$(cat /app/nodes_count) || previous_nodes_count="0"

if [ "$current_nodes_count" -eq "$previous_nodes_count" ]; then

  echo
  echo "*****************************************************"
  echo "      No changes detected to the custom nodes count "
  echo "      Previous: $current_nodes_count Current: $previous_nodes_count  "
  echo "*****************************************************"
  echo

else

  # install all requirements for the custom_nodes
  echo
  echo "*****************************************************"
  echo "      Changes detected to the custom nodes count "
  echo "      Previous: $current_nodes_count Current: $previous_nodes_count  "
  echo "      Checking all requirements.txt "
  echo "*****************************************************"
  echo

  cd /app/ComfyUI/custom_nodes/
  find . -mindepth 2 -maxdepth 2 -type f -name 'requirements.txt' -print0 | while IFS= read -r -d '' file; do

    echo
    echo "*****************************************************"
    echo "     Processing requirements for"
    echo "     $file"
    echo "*****************************************************"

    # fixed for older custom nodes
    sed -e 's/\r$//' "$file" | sort -u > temp_requirements.txt
    sed -i 's/==/>=/g' temp_requirements.txt

    # install requirements.txt
    pip install --no-input --disable-pip-version-check -r temp_requirements.txt || {
        echo "ERROR: pip install failed for: $file"
        exit 1
      }
  done

  echo "$current_nodes_count" > /app/nodes_count

fi

rocminfo | grep -E "Name:|gfx|version|Version"
clinfo | grep -i version

# Run ComfyUI and monitor shell output
set -Eeuo pipefail

# Set output keywors that will init a container restart with exit 1
KEYWORDS=(
  "Restarting"
  "Memory access fault by GPU"
)

cd /app/ComfyUI/
while IFS= read -r line; do
  printf '%s\n' "$line"

  for kw in "${KEYWORDS[@]}"; do
    if [[ "$line" == *"$kw"* ]]; then
      echo "Keyword hit ($kw) → exit 1"
      exit 1
    fi
  done

done < <(PYTHONUNBUFFERED=1 python3 -u main.py --listen 0.0.0.0 2>&1)
