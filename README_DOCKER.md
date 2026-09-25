# Running Neato Packages in Docker (Ubuntu 24.04 + ROS 2 Jazzy)

This guide explains how to set up, build, and run the [`neato_packages`](file:///home/bill/repos/neato_packages) simulation environment inside an Ubuntu 24.04 Docker container with ROS 2 Jazzy and Gazebo Harmonic, featuring full NVIDIA GPU acceleration and GUI forwarding.

---

## 1. Quick Start Workflow

Three scripts are provided to streamline the entire setup and execution:

### Step 1: Install Host Dependencies (One-Time Setup)
Run [`setup.sh`](file:///home/bill/repos/neato_packages/setup.sh) on your host Ubuntu machine to configure the NVIDIA Container Toolkit and register the NVIDIA runtime with Docker:

```bash
./setup.sh
```

### Step 2: Build the Docker Image
Run [`build_docker.sh`](file:///home/bill/repos/neato_packages/build_docker.sh) to compile the Docker image and pre-build the ROS 2 workspace:

```bash
./build_docker.sh
```

### Step 3: Launch the Container
Run [`run_docker.sh`](file:///home/bill/repos/neato_packages/run_docker.sh) to start the container with NVIDIA GPU passthrough, host networking, and X11 GUI forwarding:

```bash
./run_docker.sh
```

> **Note:** If NVIDIA GPU support is not configured or missing, [`run_docker.sh`](file:///home/bill/repos/neato_packages/run_docker.sh) will immediately fail with a specific error directing you to run `./setup.sh`.

---

## 2. Workspace & Environment (Automatic)

The container environment is **fully pre-configured and automatically sourced** upon launch.

You do **not** need to manually run `colcon build` or `source install/setup.bash` every time you start or attach to the container.

### Setting `ROS_DOMAIN_ID`

`run_docker.sh` automatically detects and forwards `ROS_DOMAIN_ID` from your host:

1. **Automatic from host environment** (e.g. if set in your host's `~/.bashrc`):
   ```bash
   export ROS_DOMAIN_ID=42
   ./run_docker.sh
   ```

2. **One-time inline launch override**:
   ```bash
   ROS_DOMAIN_ID=42 ./run_docker.sh
   ```

3. **Inside the container**:
   You can also set it dynamically in any terminal session:
   ```bash
   export ROS_DOMAIN_ID=42
   ```

> **Note on code changes:** Since `--symlink-install` is used and your repository is mounted into `/root/ros2_ws/src/neato_packages`, Python code changes made on your host take effect immediately without recompilation. If you add new custom message definitions or C++ files, simply re-run `colcon build --symlink-install` inside the container.

---

## 3. Running the Simulation

Inside the container shell, launch any of the standard simulation worlds from [`neato2_gazebo`](file:///home/bill/repos/neato_packages/neato2_gazebo):

* **Empty World**:
  ```bash
  ros2 launch neato2_gazebo empty_world.py
  ```

* **Gauntlet / Obstacle Course**:
  ```bash
  ros2 launch neato2_gazebo neato_gauntlet_world.py
  ```

* **Other Worlds**:
  - Maze: `ros2 launch neato2_gazebo neato_maze.py`
  - Bridge of Doom: `ros2 launch neato2_gazebo neato_bod.py`
  - Flatland: `ros2 launch neato2_gazebo neato_flatland_world.py`
  - Dining Hall: `ros2 launch neato2_gazebo neato_dh.py`

---

## 4. Opening Additional Terminals (Teleop & RViz)

While the simulation is running in the primary container terminal, run [`docker_shell.sh`](file:///home/bill/repos/neato_packages/docker_shell.sh) from another terminal on your host to attach to the running simulation:

```bash
./docker_shell.sh
```

From within the attached terminal session:

* **Drive the robot with keyboard**:
  ```bash
  ros2 run teleop_twist_keyboard teleop_twist_keyboard
  ```

* **Launch RViz2**:
  ```bash
  rviz2
  ```

---

## 5. Connecting to a Physical Neato Robot

Because the container runs on host networking (`--net=host`), you can communicate directly with a physical Neato over Wi-Fi without any extra configuration.

### Steps:

1. **Connect to the same Wi-Fi network** as the physical Neato (e.g. course lab Wi-Fi).
2. **Note your robot's IP address** (shown on the robot screen / Raspberry Pi).
3. **Launch the container with your assigned `ROS_DOMAIN_ID`**:
   ```bash
   ROS_DOMAIN_ID=<your-domain-id> ./run_docker.sh
   ```
4. **Bring up the physical robot driver and camera stream**:
   ```bash
   ros2 launch neato_node2 bringup.py host:=<robot-ip>
   ```
5. **Control and Visualize** (in another terminal via `./docker_shell.sh`):
   * **Keyboard teleop**: `ros2 run teleop_twist_keyboard teleop_twist_keyboard`
   * **RViz visualizer**: `rviz2`

---

## 6. Summary of Files

* [`setup.sh`](file:///home/bill/repos/neato_packages/setup.sh): Host setup script to install `nvidia-container-toolkit`, configure Docker, and restart the daemon.
* [`build_docker.sh`](file:///home/bill/repos/neato_packages/build_docker.sh): Builds the `neato-jazzy` image with pre-compiled packages.
* [`run_docker.sh`](file:///home/bill/repos/neato_packages/run_docker.sh): Launches the container with NVIDIA GPU acceleration, host networking, and X11 forwarding.
* [`docker_shell.sh`](file:///home/bill/repos/neato_packages/docker_shell.sh): Attaches an interactive shell to the running simulation/robot container.
* [`Dockerfile`](file:///home/bill/repos/neato_packages/Dockerfile): Container recipe with ROS 2 Jazzy, Gazebo Harmonic, and system dependencies.
* [`entrypoint.sh`](file:///home/bill/repos/neato_packages/entrypoint.sh): Container entrypoint script that auto-sources ROS 2 and workspace overlays.
