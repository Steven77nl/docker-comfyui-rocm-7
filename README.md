# Docker ComfyUI for AMD Radeon xf1201 ROCm 7.2

ComfyUI Docker image project to run [ComfyUI](https://github.com/comfyanonymous/ComfyUI) with AMD ROCm 7.2

Base image is the official [rocm/pytorch docker image](https://hub.docker.com/r/rocm/pytorch) from AMD with Ubuntu 24.03 and pre-installed matching ROCm 7.2 and Torch 2.9.1 software.

Originaly I build this for myself to easy deploy this as a docker setup and fine tuned it for my **Radeon AI PRO R9700 (RDNA4 / gfx1201)** setup. But I'm happy to share this with others through this [GitHub repo](https://github.com/Steven77nl/docker-comfyui-rocm-7).

It helped me to get rid of the constant **Memory access fault by GPU** issues due to incompatibility between AMD Driver / ROCm and Python Packages, these are all now correctly matched by AMD and provided through the [rocm/pytorch docker image](https://hub.docker.com/r/rocm/pytorch) on which this docker image is build on. I have a very stable setup now.

## Features
- All-in-one-Docker container
    - Ubuntu 24.04
    - ROCm 7.2.0
    - PyTorch 2.9.1
    - ComfyUI [(latest)](https://github.com/comfy-org/ComfyUI)
    - ComfyUI-Manager [(latest)](https://github.com/Comfy-Org/ComfyUI-Manager)

## Prerequisites

Required:
- A supported AMD GPU [(ROCm compatibility Matrix)](https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html)
- Ubuntu 24.04.03 Host OS *(not tested on other linux distro's)*
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
#### Enable execution on the .sh file ####
Enables that you can execute the bash scripts.
```
chmod +x *.sh
```
---
#### Build the Docker image ####
This will download the [rocm/pytorch docker image](https://hub.docker.com/r/rocm/pytorch) and installs ComfyUI and all it's python requirments.
```
./build.sh
```
---
#### Run the Docker container ####
This will start the docker container and the ComfyUI webserver.

```
./run.sh
```
You can reach the webserver locally via [http://127.0.0.1:8188/](http://127.0.0.1:8188/)


## Persistance Mount locations ##

The folders user, models, output, input and custom_nodes in the container image will be mounted to the following persistent volume locations:

- ~/.comfyui/user
- ~/.comfyui/models
- ~/.comfyui/output
- ~/.comfyui/input
- ~/.comfyui/custom_nodes

You can change these destinations in the **docker-compose.yml** file.
Container app runs with your local user, so ownership and permissions on these created persistent storage and files will be your host user account.

## Runtime checks ##

When it's a fresh container it will check if the ComfyUI Manager is already available in the persistent custom_nodes volume mount **|~/.comfyui/custom_nodes|** and otherwise will download and install this.

At each run it will check if the count of custom_nodes folder in the spersistant custom_nodes volume mount **|~/.comfyui/custom_nodes|** has changed compared to the last run. If this is the case it will re-check all requirement.txt files to install missing pythong packages before stating the webserver.

When certain console output text is detected from the ComfyUI Webserver, it will initiate a restart of the container.

## Support me ##

[Just buy me a coffee !!](https://buymeacoffee.com/steven77nl)

:coffee:

Thank you !
