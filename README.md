# Kinesis RB-CAR ROS 1 Workspace

This repository is the onboarding workspace for Kinesis CTP students working
with the Robotnik RB-CAR in ROS 1 Noetic.

It provides:

- a ROS 1 Noetic Docker environment for Ubuntu 24.04 and newer hosts;
- `.repos` manifests for the Kinesis RB-CAR forks;
- a standard catkin workspace layout;
- a repeatable local test flow for `roscore`, RViz, and RB-CAR packages.

## Repository Layout

```text
.
├── containers/ros1_noetic/     # Docker-based ROS 1 Noetic dev environment
├── rbcar_kinesis_https.repos   # read-only/simple clone manifest
├── rbcar_kinesis_ssh.repos     # contributor manifest for Kinesis members
├── scripts/                    # workspace helper scripts
└── src/                        # ROS packages imported by vcs
```

The RB-CAR source packages live in separate Kinesis forks:

- `KinesisCTP/rbcar_common`
- `KinesisCTP/rbcar_sim`
- `KinesisCTP/robotnik_msgs`
- `KinesisCTP/robotnik_sensors`

Robotnik's original repositories should remain as upstream references for
vendor updates.

## Prerequisites

Install Docker Engine and make sure it works without `sudo`:

```bash
docker run hello-world
```

If Docker was just installed and your user was added to the `docker` group, open
a new terminal or run:

```bash
newgrp docker
```

For GUI tools such as RViz, use a Linux desktop session with X11 available. The
container launcher passes through X11 and `/dev/dri` for OpenGL.

## Quick Start

Clone this umbrella workspace:

```bash
git clone https://github.com/KinesisCTP/rb-car.git ~/rb-car_ws
cd ~/rb-car_ws
```

Start the ROS 1 Noetic container:

```bash
./containers/ros1_noetic/run.sh
```

Inside the container, import the RB-CAR source packages:

```bash
vcs import src < rbcar_kinesis_https.repos
```

Install missing ROS package dependencies, then build:

```bash
rosdep update
rosdep install --from-paths src --ignore-src -r -y
catkin_make
source devel/setup.bash
```

## Local RViz Test

Use this when testing without a physical robot.

Terminal 1:

```bash
cd ~/rb-car_ws
./containers/ros1_noetic/run.sh
roscore
```

Terminal 2:

```bash
cd ~/rb-car_ws
./containers/ros1_noetic/enter.sh
rviz
```

If RViz opens but rendering is broken:

```bash
LIBGL_ALWAYS_SOFTWARE=1 rviz
```

## Working With a Real RB-CAR

Copy the environment template:

```bash
cd ~/rb-car_ws/containers/ros1_noetic
cp .env.example .env
```

Edit `.env` so `ROS_MASTER_URI` points at the robot and `ROS_IP` is your
workstation's IP address on the robot network:

```bash
ROS_MASTER_URI=http://<robot-ip>:11311
ROS_IP=<your-workstation-ip>
```

Find your workstation IP with:

```bash
ip -4 addr show
```

Do not leave `ROS_IP` set to a placeholder or stale network address. If
`roscore` reports that it cannot contact its own server, check:

```bash
echo "$ROS_MASTER_URI"
echo "$ROS_IP"
ping "$ROS_IP"
```

## Contributor Setup

Students with write access to the Kinesis organization should configure GitHub
SSH access, then import using the SSH manifest:

```bash
vcs import src < rbcar_kinesis_ssh.repos
```

If packages were initially imported with HTTPS, switch their `origin` remotes to
SSH:

```bash
./scripts/use_ssh_remotes.sh
```

Recommended remote layout inside each source repo:

```text
origin   -> git@github.com:KinesisCTP/<repo>.git
upstream -> git@github.com:RobotnikAutomation/<repo>.git
```

Use feature branches for changes:

```bash
cd src/rbcar_common
git switch -c feature/my-change
```

## Updating From Robotnik Upstream

For each package repo, keep Robotnik as `upstream`:

```bash
git remote add upstream git@github.com:RobotnikAutomation/<repo>.git
git fetch upstream
```

Then merge or rebase upstream changes intentionally into the Kinesis branch.

## Useful Checks

Inside the container:

```bash
whoami
echo "$ROS_DISTRO"
xeyes
glxinfo -B
rospack profile
catkin_make
```
