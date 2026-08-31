# Neato Packages & Gazebo Simulation Setup

This repository contains the ROS 2 packages used for interfacing with physical Neato robots and running Neato simulations in Gazebo Harmonic for [CompRobo (Computational Introduction to Robotics)](https://comprobo26.github.io/).

> [!TIP]
> **Using Docker?**
> If you are on an older Ubuntu distribution (e.g. 22.04 LTS) or prefer an isolated, pre-configured container environment, see **[README_DOCKER.md](README_DOCKER.md)** for one-command setup, simulation launch, and physical robot connectivity instructions.

---

## 1. Prerequisites & Dependencies

The standard course environment uses **Ubuntu 24.04 (Noble Numbat)** and **ROS 2 Jazzy Jalisco** with **Gazebo Harmonic**.

### Install System & ROS 2 Packages

```bash
sudo apt update && sudo apt install -y \
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
    gstreamer1.0-libav gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    hping3 \
    git
```

### Install Python Dependencies & Permissions

```bash
pip3 install --break-system-packages scikit-build opencv-python
sudo setcap cap_net_raw+ep /usr/sbin/hping3
```

---

## 2. Workspace Setup & Build

1. **Create your ROS 2 workspace**:
   ```bash
   mkdir -p ~/ros2_ws/src
   ```

2. **Clone or link this repository** into `~/ros2_ws/src`:
   ```bash
   # If cloning:
   cd ~/ros2_ws/src
   git clone git@github.com:comprobo26/neato_packages.git

   # Or if this repository is already checked out elsewhere (e.g. ~/repos/neato_packages):
   ln -s ~/repos/neato_packages ~/ros2_ws/src/neato_packages
   ```

3. **Build the workspace** using `colcon`:
   ```bash
   source /opt/ros/jazzy/setup.bash
   cd ~/ros2_ws
   colcon build --symlink-install
   ```

4. **Source your workspace**:
   ```bash
   source ~/ros2_ws/install/setup.bash
   ```

---

## 3. Environment Configuration

Add sourcing commands and your assigned `ROS_DOMAIN_ID` to your `~/.bashrc` file to ensure they are loaded in every terminal session:

```bash
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
echo "export ROS_DOMAIN_ID=<your-assigned-domain-id>" >> ~/.bashrc
source ~/.bashrc
```

---

## 4. Running the Gazebo Simulation

Launch files are provided in the `neato2_gazebo` package to run the Neato in various simulated worlds.

### Empty World
```bash
ros2 launch neato2_gazebo empty_world.py
```

### Gauntlet / Obstacle World
```bash
ros2 launch neato2_gazebo neato_gauntlet_world.py
```

### Other Available Worlds
- **Maze**:
  ```bash
  ros2 launch neato2_gazebo neato_maze.py
  ```
- **Bridge of Doom**:
  ```bash
  ros2 launch neato2_gazebo neato_bod.py
  ```
- **Flatland**:
  ```bash
  ros2 launch neato2_gazebo neato_flatland_world.py
  ```
- **Dining Hall**:
  ```bash
  ros2 launch neato2_gazebo neato_dh.py
  ```

---

## 5. Controlling & Visualizing the Robot

### Keyboard Teleoperation
To drive the robot using your keyboard in a new terminal:
```bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

### RViz2 Visualization
To view sensor data and transforms in RViz:
```bash
rviz2
```

### Common Topics

| Topic | Type | Description |
| :--- | :--- | :--- |
| `/cmd_vel` | `geometry_msgs/msg/Twist` | Velocity commands to drive the Neato |
| `/scan` | `sensor_msgs/msg/LaserScan` | 2D LiDAR scan data |
| `/odom` | `nav_msgs/msg/Odometry` | Odometry position and velocity |
| `/camera/image_raw` | `sensor_msgs/msg/Image` | Camera feed |
| `/imu` | `sensor_msgs/msg/Imu` | Inertial Measurement Unit data |
| `/bump` | `neato2_interfaces/msg/Bump` | Bump sensor state |

---

## 6. Included Packages

- `neato2_gazebo`: Gazebo Harmonic simulation launch files, SDF models, and worlds.
- `neato_node2`: ROS 2 drivers and bridge adapters for the Neato robot.
- `fix_scan`: Utilities for LiDAR scan processing and point cloud generation (`scan_to_pc2`).
- `neato2_interfaces`: Custom ROS 2 interfaces and messages (e.g. `Bump`).
