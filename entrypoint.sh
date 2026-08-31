#!/usr/bin/env bash
set -e

# Source ROS 2 base environment
source /opt/ros/jazzy/setup.bash

# Build workspace if install directory does not exist yet
if [ ! -f /root/ros2_ws/install/setup.bash ]; then
    echo "First-time workspace setup: building packages..."
    cd /root/ros2_ws && colcon build --symlink-install
fi

# Source workspace environment
if [ -f /root/ros2_ws/install/setup.bash ]; then
    source /root/ros2_ws/install/setup.bash
fi

if [ -n "${ROS_DOMAIN_ID}" ]; then
    echo "[ROS 2] Active ROS_DOMAIN_ID=${ROS_DOMAIN_ID}"
fi

exec "$@"
