#!/usr/bin/env bash
set -e

# Resolve the absolute path of this repository
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verify NVIDIA Container Toolkit is installed and functioning
if ! which nvidia-ctk >/dev/null 2>&1 && ! which nvidia-container-runtime >/dev/null 2>&1; then
    echo "========================================================================" >&2
    echo " [ERROR] NVIDIA Container Toolkit is NOT installed on this host!" >&2
    echo "" >&2
    echo " Docker requires 'nvidia-container-toolkit' to access your NVIDIA GPU." >&2
    echo " Please run the host setup script first:" >&2
    echo "" >&2
    echo "     ./setup.sh" >&2
    echo "" >&2
    echo "========================================================================" >&2
    exit 1
# Verify Docker image has been built
if ! docker image inspect neato-jazzy >/dev/null 2>&1; then
    echo "========================================================================" >&2
    echo " [ERROR] Docker image 'neato-jazzy' not found!" >&2
    echo "" >&2
    echo " Please build the Docker image first by running:" >&2
    echo "" >&2
    echo "     ./build_docker.sh" >&2
    echo "" >&2
    echo "========================================================================" >&2
    exit 1
fi

# Quick test if Docker daemon can run with --gpus all
if ! docker run --rm --gpus all neato-jazzy echo "test" >/dev/null 2>&1; then
    echo "========================================================================" >&2
    echo " [ERROR] Docker daemon cannot access the NVIDIA GPU driver (--gpus all)." >&2
    echo "" >&2
    echo " The NVIDIA runtime is not configured or Docker needs to be restarted." >&2
    echo " Please run the host setup script to configure and restart Docker:" >&2
    echo "" >&2
    echo "     ./setup.sh" >&2
    echo "" >&2
    echo "========================================================================" >&2
    exit 1
fi

# Allow local GUI / X11 connections
xhost +local:root > /dev/null 2>&1

# Check for ROS_DOMAIN_ID on host
ENV_FLAGS=()
if [ -n "${ROS_DOMAIN_ID}" ]; then
    echo "  -> Passing ROS_DOMAIN_ID=${ROS_DOMAIN_ID} into container."
    ENV_FLAGS+=("-e" "ROS_DOMAIN_ID=${ROS_DOMAIN_ID}")
else
    echo "  -> ROS_DOMAIN_ID is not set on host (defaulting to 0)."
fi

docker run -it --rm \
    --name neato_sim \
    --net=host \
    --ipc=host \
    --gpus all \
    "${ENV_FLAGS[@]}" \
    -e DISPLAY="${DISPLAY}" \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "${REPO_DIR}:/root/ros2_ws/src/neato_packages" \
    neato-jazzy "$@"
