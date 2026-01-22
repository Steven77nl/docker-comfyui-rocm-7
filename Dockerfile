FROM alpine/git:latest AS builder

# source docker image preinstalled with AMD ROCm 7.2
FROM rocm/pytorch:rocm7.2_ubuntu24.04_py3.12_pytorch_release_2.9.1

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Allow passing in your host user UID/GID during build (defaults 1000/1000)
ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000

# Install base tooling
RUN apt-get update
RUN apt-get install -y rocm rocminfo unzip libgl1 libglib2.0-0 libstdc++-12-dev libsndfile1 ffmpeg
RUN apt-get install -y --no-install-recommends google-perftools

# Create user account, assign groups and to own python venv
RUN groupadd -g ${HOST_USER_GID} appuser
RUN useradd -m -d /app -s /bin/bash -g appuser -u ${HOST_USER_UID} appuser
RUN chown -R appuser:appuser /opt/venv
RUN chmod 2775 /app

# Switch to non-root user
USER appuser
ENV PATH="/opt/venv/bin:${PATH}"

# create application folder and set as working dir
WORKDIR /app

# download latest ComfyUI version
RUN wget https://github.com/Comfy-Org/ComfyUI/archive/refs/heads/master.zip
RUN unzip master.zip && mv ComfyUI-master ComfyUI && rm master.zip

# Backup  standard models (we copy these files back later at first run)
RUN mv /app/ComfyUI/models /app/ComfyUI/models_repo
RUN mv /app/ComfyUI/custom_nodes /app/ComfyUI/custom_nodes_repo

# Install core requirements for ComfyUI
RUN pip install -r /app/ComfyUI/requirements.txt
RUN pip install -r /app/ComfyUI/manager_requirements.txt

# Create Volumes Mount Points
VOLUME ["/app/ComfyUI/user"]
VOLUME ["/app/ComfyUI/models"]
VOLUME ["/app/ComfyUI/output"]
VOLUME ["/app/ComfyUI/input"]
VOLUME ["/app/ComfyUI/custom_nodes"]

# Switch back to root user
USER root

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# cleanup
RUN pip3 cache purge
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean -y

EXPOSE 8188

USER appuser
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python","/app/ComfyUI/main.py","--listen","0.0.0.0"]
