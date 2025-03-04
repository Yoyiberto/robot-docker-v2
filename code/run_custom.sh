#!/bin/bash

# Debug log - Start of script
echo "Starting robot visualization and IK calculation..."

# Source ROS setup
source /opt/ros/noetic/setup.bash

# Start virtual display for rendering
Xvfb :1 -screen 0 1024x768x24 &
sleep 2

# Create directories for robot visualization
mkdir -p /code/robot_visualization/urdf
mkdir -p /code/robot_visualization/meshes

# Copy URDF and meshes to the ROS package
cp /data/R7X_stl_v4.urdf /code/robot_visualization/urdf/
cp /data/meshes/*.stl /code/robot_visualization/meshes/

# Fix mesh paths in URDF
sed -i 's|package://your_robot_package/meshes|package://robot_visualization/meshes|g' /code/robot_visualization/urdf/R7X_stl_v4.urdf

# Debug log - Files copied
echo "URDF and mesh files copied to ROS package"

# Make the Python script executable
chmod +x /code/robot_visualization/ik_visualization.py

# Debug log - Python script created
echo "Python script for IK calculation and visualization ready"

# Run the Python script
cd /code
python3 /code/robot_visualization/ik_visualization.py

# Debug log - Script execution completed
echo "Robot visualization and IK calculation completed!"

# List the output files
echo "Output files:"
ls -la /results/

# Exit with success
exit 0 