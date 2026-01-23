# Docker ComfyUI for AMD Radeon gfx1201 ROCm 7.2

A Docker image for running [ComfyUI](https://github.com/comfyanonymous/ComfyUI) with AMD ROCm 7.2.

The base image is AMD's official [rocm/pytorch Docker image](https://hub.docker.com/r/rocm/pytorch) using Ubuntu 24.04, with ROCm 7.2 and PyTorch 2.9.1 preinstalled.

Originally, I built this to easily deploy ComfyUI as a Docker setup and fine-tuned it for my **Radeon AI PRO R9700 (RDNA4 / gfx1201)** setup. I'm happy to share it with others through this [GitHub repository](https://github.com/Steven77nl/docker-comfyui-rocm-7).

It resolved the recurring **Memory access fault by GPU** errors caused by incompatibilities between AMD drivers/ROCm and Python packages; these are now correctly matched by AMD and provided via the [rocm/pytorch Docker image](https://hub.docker.com/r/rocm/pytorch) upon which this Docker image is built. I have a very stable setup now.

## Features
- All-in-one Docker container
    - Ubuntu 24.04
    - ROCm 7.2.0
    - PyTorch 2.9.1
    - ComfyUI [(latest)](https://github.com/comfy-org/ComfyUI)
    - ComfyUI-Manager [(latest)](https://github.com/Comfy-Org/ComfyUI-Manager)

## Prerequisites

Required:
- A supported AMD GPU [(ROCm Compatibility Matrix)](https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html)
- Ubuntu 24.04.3 Host OS *(not tested on other Linux distros)*
- Latest [AMD GPU Drivers](https://instinct.docs.amd.com/projects/amdgpu-docs/en/latest/install/detailed-install/package-manager/package-manager-ubuntu.html) installed
- [Docker CE](https://bckinfo.com/how-to-install-docker-ce-on-ubuntu-24-04/) installed

Optional:
- Latest [ROCm Software](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/install-methods/package-manager/package-manager-ubuntu.html) installed

## Getting Started

#### Clone the repo to your local computer ####
```
git clone https://github.com/Steven77nl/docker-comfyui-rocm-7
cd docker-comfyui-rocm-7
```
---
#### Make the .sh files executable ####
Makes the bash scripts executable.
```
chmod +x *.sh
```
---
#### Build the Docker image ####
This will download the [rocm/pytorch docker image](https://hub.docker.com/r/rocm/pytorch) and install ComfyUI and all its Python requirements.
```
./build.sh
```
---
#### Run the Docker container ####
This will start the Docker container and the ComfyUI web server.

```
./run.sh
```
You can reach the web server locally via [http://127.0.0.1:8188/](http://127.0.0.1:8188/)


## Persistent Mount Locations ##

The folders user, models, output, input, and custom_nodes in the container image will be mounted to the following persistent volume locations:

- ~/.comfyui/user
- ~/.comfyui/models
- ~/.comfyui/output
- ~/.comfyui/input
- ~/.comfyui/custom_nodes

You can change these destinations in the **docker-compose.yml** file.
The container app runs as your local user, so ownership and permissions on the created persistent storage and files will match your host user account.

## Runtime Checks ##

On first run, the container checks whether ComfyUI Manager is present in the persistent custom_nodes volume (`~/.comfyui/custom_nodes`). If not, it will download and install it.

On each run, it checks whether the number of items in the custom_nodes folder in the persistent volume (`~/.comfyui/custom_nodes`) has changed compared to the last run. If so, it will re-check all requirements.txt files to install missing Python packages before starting the web server.

If specific console output is detected from the ComfyUI web server, the container will restart.

## Support me ##

[Buy me a coffee](https://buymeacoffee.com/steven77nl)

:coffee:

Thank you!
