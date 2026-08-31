#!/usr/bin/env bash
set -e

echo "========================================================="
echo "  Setting up Host Dependencies for Neato Docker (NVIDIA) "
echo "========================================================="

# 1. Configure NVIDIA Container Toolkit APT repository if needed
if ! dpkg -l | grep -q nvidia-container-toolkit; then
    echo "--> Configuring NVIDIA Container Toolkit repository..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg --yes
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
fi

# 2. Install NVIDIA Container Toolkit
echo "--> Installing nvidia-container-toolkit..."
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 3. Configure Docker daemon to register NVIDIA runtime
echo "--> Configuring Docker daemon for NVIDIA runtime..."
sudo nvidia-ctk runtime configure --runtime=docker

# 4. Restart Docker daemon
echo "--> Restarting Docker service..."
sudo systemctl restart docker

# 5. Verify NVIDIA GPU passthrough in Docker
echo "--> Verifying NVIDIA GPU access in Docker..."
if docker run --rm --gpus all ubuntu:22.04 nvidia-smi > /dev/null 2>&1; then
    echo "========================================================="
    echo "  SUCCESS: NVIDIA GPU Docker support is ready!"
    echo "  You can now run: ./build_docker.sh && ./run_docker.sh"
    echo "========================================================="
else
    echo "========================================================="
    echo "  WARNING: Docker restart succeeded, but test GPU run failed."
    echo "  You may need to log out and log back in, or check 'nvidia-smi'."
    echo "========================================================="
fi
