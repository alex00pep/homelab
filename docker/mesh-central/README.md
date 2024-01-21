
# Meshcentral-Docker
![Docker Pulls](https://img.shields.io/docker/pulls/typhonragewind/meshcentral?style=flat-square)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/typhonragewind/meshcentral?style=flat-square)

## Source

https://raw.githubusercontent.com/Typhonragewind/meshcentral-docker/main/README.md
## About
This is my implementation of the amazing MeshCentral software (https://github.com/Ylianst/MeshCentral) on a docker image, with some minor QOL settings to make it easier to setup.

While easier to setup and get up and running, you should still peer through the very informative official guides:

https://meshcentral.com/info/docs/MeshCentral2InstallGuide.pdf

https://meshcentral.com/info/docs/MeshCentral2UserGuide.pdf

## Disclaimer

This image is targeted for self-hosting and small environments. The regular image does **not** make use of a specialized database solution (MongoDB) and as such, per official documentation is not recommended for environments for over 100 devices.

## Installation

The preferred method to get this image up and running is through the use of *docker-compose* (examples below).

By filling out some of the options in the environment variables in the docker compose you can define some initial meshcentral settings and have it up and ready in no time. If you'd like to include settings not supported by the docker-compose file, you can also edit the config.json to your liking (you should really check the User's Guide for this) and place it in the meshcentral-data folder **before** initializing the container.

Updating settings is also easy after having the container initialized if you change your mind or want to tweak things. Just edit meshcentral-data/config.json and restart the container.

```bash
docker compose up -d
```
