FROM alpine/git:latest AS builder

# source docker image preinstalled with AMD ROCm 7.1.1
FROM rocm/dev-ubuntu-24.04:7.1.1

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Install base tooling
RUN apt-get update
RUN apt-get install -y git wget python3-pip python3-venv libstdc++-12-dev python3-setuptools python3-wheel rocm rocminfo libsndfile1 ffmpeg libgl1 libglib2.0-0
RUN apt-get install -y --no-install-recommends google-perftools

# clone latest ConfyUI
RUN git clone https://github.com/comfy-org/ComfyUI /comfyui

# Set working directory
WORKDIR /comfyui
SHELL ["/bin/bash", "-c"]

# Secure standard models
RUN mv /comfyui/models /comfyui/models_repo

# Install PyTorch for ROCm 7.1.1
RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.1.1/triton-3.5.1%2Brocm7.1.1.gita272dfa8-cp312-cp312-linux_x86_64.whl
RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.1.1/torch-2.9.1%2Brocm7.1.1.lw.git351ff442-cp312-cp312-linux_x86_64.whl
RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.1.1/torchvision-0.24.0%2Brocm7.1.1.gitb919bd0c-cp312-cp312-linux_x86_64.whl
RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.1.1/torchaudio-2.9.0%2Brocm7.1.1.gite3c6ee2b-cp312-cp312-linux_x86_64.whl

# Install Remaining Requirements for ComfyUI
RUN pip install -r "requirements.txt"
RUN pip install -r "manager_requirements.txt"

# Install Specific Node Dependencies
COPY nodes_requirements.txt /nodes_requirements.txt
RUN pip install -r "/nodes_requirements.txt"

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8188
ENTRYPOINT ["/entrypoint.sh"]
