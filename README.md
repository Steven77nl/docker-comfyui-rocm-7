# Docker ComfyUI for AMD Radeon xf1201 ROCm 7.1.1

ComfyUI Docker image project to run [ComfyUI](https://github.com/comfyanonymous/ComfyUI) with AMD ROCm 7.2
Base image is the official [rocm/pytorch docker image](https://hub.docker.com/r/rocm/pytorch) from AMD
Build for and tested with my Radeon AI PRO R9700 (gfx1201)

## Features
- All-in-one-Docker container
- Ubunty 24.03
- ROCm 7.2
- PyTorch 2.9.1
- ComfyUI (latest)
- ComfyUI-Manager (latest)

## Prerequisites

- AMD GPU (gfx1201) Hardware
- Latest [AMD GPU Drivers](https://instinct.docs.amd.com/projects/amdgpu-docs/en/latest/install/detailed-install/package-manager/package-manager-ubuntu.html) installed
- Docker installed on your system

## Getting Started

- Clone the repo to your local computer:
git clone https://github.com/Steven77nl/docker-comfyui-rocm-7

- Enable execution on the .sh file
chmod +x *.sh

- Build the Docker image
./build.sh

- Run the Docker container
./run.sh

## VOoume Mount locations

The folders user, models, output, input and custom_nodes will be placed on the host system at the following locations:

~/.comfyui/user
~/.comfyui/models
~/.comfyui/output
~/.comfyui/input
~/.comfyui/custom_nodes

You can change these destinations in the docker-compose.yml file
Container app runs with your local user, so file permissions
