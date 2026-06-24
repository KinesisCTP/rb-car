FROM osrf/ros:noetic-desktop-full

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=1000
ARG VIDEO_GID=44
ARG RENDER_GID=109

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && if ! getent group ${VIDEO_GID} >/dev/null; then groupadd --gid ${VIDEO_GID} video-host; fi \
    && if ! getent group ${RENDER_GID} >/dev/null; then groupadd --gid ${RENDER_GID} render-host; fi \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && usermod --append --groups ${VIDEO_GID},${RENDER_GID} ${USERNAME} \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        git \
        iputils-ping \
        mesa-utils \
        net-tools \
        python3-catkin-tools \
        python3-rosdep \
        python3-vcstool \
        sudo \
        tmux \
        vim \
        x11-apps \
        ros-noetic-gazebo-plugins \
        ros-noetic-gazebo-ros \
        ros-noetic-hector-gazebo-plugins \
        ros-noetic-robot-localization \
        ros-noetic-robot-state-publisher \
        ros-noetic-twist-mux \
        ros-noetic-velocity-controllers \
        ros-noetic-xacro \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}
WORKDIR /home/${USERNAME}/rb-car_ws

RUN echo 'source /opt/ros/noetic/setup.bash' >> /home/${USERNAME}/.bashrc \
    && echo 'if [ -n "$ROS_WORKSPACE" ] && [ -f "$ROS_WORKSPACE/devel/setup.bash" ]; then source "$ROS_WORKSPACE/devel/setup.bash"; elif [ -f "$HOME/rb-car_ws/devel/setup.bash" ]; then source "$HOME/rb-car_ws/devel/setup.bash"; fi' >> /home/${USERNAME}/.bashrc

CMD ["bash"]
