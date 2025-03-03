FROM registry.codeocean.com/codeocean/ubuntu:20.04.2

ARG DEBIAN_FRONTEND=noninteractive

# Install ROS Noetic
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list \
    && apt-get update && apt-get install -y \
    ros-noetic-ros-base \
    ros-noetic-robot-state-publisher \
    ros-noetic-joint-state-publisher \
    ros-noetic-xacro \
    ros-noetic-kdl-parser \
    ros-noetic-kdl-parser-py \
    ros-noetic-tf \
    ros-noetic-tf-conversions \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Install Python dependencies
RUN pip3 install \
    numpy \
    matplotlib \
    pyyaml \
    rospkg \
    PyKDL \
    transforms3d \
    ikpy

# Install additional tools for visualization
RUN apt-get update && apt-get install -y \
    xvfb \
    mesa-utils \
    libosmesa6-dev \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Set up ROS environment
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Set working directory
WORKDIR /code

# Create entrypoint
COPY code/run.sh /code/run.sh
RUN chmod +x /code/run.sh

# Set environment variables
ENV PYTHONPATH=$PYTHONPATH:/opt/ros/noetic/lib/python3/dist-packages
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ros/noetic/lib
ENV ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:/code
ENV ROS_MASTER_URI=http://localhost:11311
ENV DISPLAY=:1

# Debug logs
RUN echo "Dockerfile setup complete. ROS Noetic installed with Python 3 support." 