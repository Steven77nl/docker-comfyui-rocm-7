FROM alpine/git:latest AS builder

# source docker image preinstalled with AMD ROCm 7.2
FROM rocm/pytorch:rocm7.2_ubuntu24.04_py3.12_pytorch_release_2.9.1

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Install tooling
RUN apt-get update
RUN apt-get install -y git rocm rocminfo libgl1 libglib2.0-0 libstdc++-12-dev libsndfile1 ffmpeg
RUN apt-get install -y --no-install-recommends google-perftools

# Fixing security on system python venv
#RUN chown -R "root:root" /opt/venv
RUN chmod -R 2777 /opt/venv

# create cache folder
RUN mkdir /.cache
RUN chmod -R 2777 /.cache

# create application folder and set as working dir
RUN mkdir /app
WORKDIR /app

# download latest ComfyUI version
RUN git clone https://github.com/Comfy-Org/ComfyUI
RUN chmod -R 6777 /app

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

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod 4775 /entrypoint.sh

# cleanup
RUN pip3 cache purge
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean -y

EXPOSE 8188
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python","/app/ComfyUI/main.py","--listen","0.0.0.0"]
