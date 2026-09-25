#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building Neato ROS 2 Jazzy Docker image (neato-jazzy)..."
cd "${REPO_DIR}"
docker build -t neato-jazzy . "$@"

echo "========================================================="
echo "  Build successful! Run ./run_docker.sh to start."
echo "========================================================="
