#!/usr/bin/env bash
set -e

CONTAINER_NAME="neato_sim"

# Check if the container is currently running
if ! docker ps --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
    echo "========================================================================" >&2
    echo " [ERROR] No running Neato container ('${CONTAINER_NAME}') was found!" >&2
    echo "" >&2
    echo " Please start the primary container first in another terminal:" >&2
    echo "" >&2
    echo "     ./run_docker.sh" >&2
    echo "" >&2
    echo " Once the container is running, run ./docker_shell.sh to open extra shells" >&2
    echo " (e.g. for teleop, RViz, or running ROS 2 nodes)." >&2
    echo "========================================================================" >&2
    exit 1
fi

echo "Attaching shell to running '${CONTAINER_NAME}' container..."

# Execute interactive bash session inside the container
docker exec -it "${CONTAINER_NAME}" bash "$@"
