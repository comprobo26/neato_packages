FROM osrf/ros:jazzy-desktop

ENV DEBIAN_FRONTEND=noninteractive

# Install system and ROS 2 Jazzy dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-ros-gz \
    ros-jazzy-nav2-bringup \
    ros-jazzy-navigation2 \
    ros-jazzy-camera-info-manager \
    ros-jazzy-cartographer-ros \
    ros-jazzy-cartographer \
    ros-jazzy-gscam \
    ros-jazzy-teleop-twist-keyboard \
    python3-colcon-common-extensions \
    python3-pip \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    hping3 \
    git \
    mesa-utils \
    libgl1-mesa-dri \
    python3-opencv \
    && rm -rf /var/lib/apt/lists/*

# Install scikit-build via pip
RUN pip3 install --break-system-packages scikit-build

# Set network capture capabilities for hping3 (video streaming)
RUN setcap cap_net_raw+ep /usr/sbin/hping3

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Setup ROS 2 workspace and copy current repository
WORKDIR /root/ros2_ws
COPY . /root/ros2_ws/src/neato_packages

SHELL ["/bin/bash", "-c"]

# Pre-build workspace during image build
RUN source /opt/ros/jazzy/setup.bash && \
    colcon build --symlink-install

# Configure environment in ~/.bashrc for interactive shells
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "if [ -f /root/ros2_ws/install/setup.bash ]; then source /root/ros2_ws/install/setup.bash; fi" >> /root/.bashrc

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
