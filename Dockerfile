FROM alpine/git:latest AS builder

# source docker image preinstalled with AMD ROCm 7.1.1
FROM rocm/pytorch:rocm7.1.1_ubuntu24.04_py3.12_pytorch_release_2.9.1

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Allow passing in your host user UID/GID (defaults 1000/1000)
ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000

# Allow passing in your host video/render GID's (defaults 44/109)
ARG HOST_VIDEO_GID=44
ARG HOST_RENDER_GID=109

# Install base tooling
RUN apt-get update
RUN apt-get install -y git wget unzip python3-pip python3-venv python3-setuptools python3-wheel
RUN apt-get install -y rocm rocminfo libgl1 libglib2.0-0 libglx-mesa0 libstdc++-12-dev libsndfile1 ffmpeg
RUN apt-get install -y --no-install-recommends google-perftools

# Create groups matching with host
RUN groupadd -g ${HOST_VIDEO_GID} video   || groupmod -g ${HOST_VIDEO_GID} video   || true
RUN groupadd -g ${HOST_RENDER_GID} render || groupmod -g ${HOST_RENDER_GID} render || true
RUN groupadd -g ${HOST_USER_GID} appuser

# Create user account
RUN useradd -m -d /app -s /bin/bash -g ${HOST_USER_GID} -u ${HOST_USER_UID} appuser
RUN usermod -aG root,video,render appuser

# Switch to non-root user
USER $HOST_USER_UID:$HOST_USER_GID

# create application folder and set as working dir
WORKDIR /app

# download latest ComfyUI version
RUN wget https://github.com/Comfy-Org/ComfyUI/archive/refs/heads/master.zip
RUN unzip master.zip && mv ComfyUI-master ComfyUI && rm master.zip

# setup the environment
RUN python3 -m venv /app/ComfyUI_venv
ENV PATH="/app/ComfyUI_venv/bin:$PATH"

# # Install PyTorch for ROCm 7.1.1
# RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.1.1/triton-3.5.1%2Brocm7.1.1.gita272dfa8-cp312-cp312-linux_x86_64.whl
# RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.1.1/torch-2.9.1%2Brocm7.1.1.lw.git351ff442-cp312-cp312-linux_x86_64.whl
# RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.1.1/torchvision-0.24.0%2Brocm7.1.1.gitb919bd0c-cp312-cp312-linux_x86_64.whl
# RUN pip install https://repo.radeon.com/rocm/manylinux/rocm-rel-7.1.1/torchaudio-2.9.0%2Brocm7.1.1.gite3c6ee2b-cp312-cp312-linux_x86_64.whl

# Install core requirements for ComfyUI
RUN pip install -r /app/ComfyUI/requirements.txt -r /app/ComfyUI/manager_requirements.txt

# Backup  standard models (we copy these files back later at first run)
RUN mv /app/ComfyUI/models /app/ComfyUI/models_repo
RUN mv /app/ComfyUI/custom_nodes /app/ComfyUI/custom_nodes_repo

# Create Volumes Mount Points
VOLUME ["/app/ComfyUI/user"]
VOLUME ["/app/ComfyUI/models"]
VOLUME ["/app/ComfyUI/output"]
VOLUME ["/app/ComfyUI/input"]
VOLUME ["/app/ComfyUI/custom_nodes"]

# Switch to root user
USER root

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# cleanup
RUN pip3 cache purge
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean -y

EXPOSE 8188
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python","/app/ComfyUI/main.py","--listen","0.0.0.0"]
