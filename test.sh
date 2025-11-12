#!/bin/bash

# Build the Debian base image
ctmgr pool build --pool debian --user devops --password changeme  --dockerfile dockerfiles/Dockerfile.debian

# Allocate a VM-like container
ctmgr alloc --pool debian --name vm1

# Render Compose config
ctmgr render-compose --pool debian --count 1 > docker-compose.override.yml

# Bring it up
docker-compose up -d
