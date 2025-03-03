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

# Create Python script for IK calculation and visualization
cat > /code/robot_visualization/ik_visualization.py << EOF
#!/usr/bin/env python3

import os
import sys
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import PyKDL as kdl
from urdf_parser_py.urdf import URDF
import kdl_parser_py.urdf as kdl_parser
import tf.transformations as tf_trans
import ikpy.chain
from ikpy.utils import plot

# Debug log
print("Starting IK calculation and visualization...")

# Load URDF
robot_urdf_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'urdf/R7X_stl_v4.urdf')
print(f"Loading URDF from: {robot_urdf_path}")
robot = URDF.from_xml_file(robot_urdf_path)

# Create KDL tree
ok, tree = kdl_parser.treeFromFile(robot_urdf_path)
if not ok:
    print("Failed to parse URDF to KDL tree")
    sys.exit(1)

# Get KDL chain from base to end effector
chain = tree.getChain("base", "endeffector")
print(f"KDL chain created with {chain.getNrOfJoints()} joints")

# Create IK solver using ikpy
ikpy_chain = ikpy.chain.Chain.from_urdf_file(
    robot_urdf_path,
    base_elements=["base"],
    active_links_mask=[True] * 6,  # 6 joints
    name="robot_arm"
)

# Target position for IK (from the image: 2.52, 0.86, -1.58)
target_position = [2.52, 0.86, -1.58]
print(f"Target position for IK: {target_position}")

# Solve IK
ik_solution = ikpy_chain.inverse_kinematics(target_position)
print(f"IK solution (joint angles): {ik_solution}")

# Forward kinematics to verify solution
fk_result = ikpy_chain.forward_kinematics(ik_solution)
end_effector_position = fk_result[:3, 3]
print(f"Forward kinematics result: {end_effector_position}")

# Create 3D plot
fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

# Plot robot
ikpy_chain.plot(ik_solution, ax, show=False)

# Plot target position
ax.scatter(target_position[0], target_position[1], target_position[2], color='green', s=100, label='Target')

# Add coordinate labels and grid
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
ax.grid(True)

# Add target position text
ax.text(target_position[0], target_position[1], target_position[2], 
        f"({target_position[0]:.2f}, {target_position[1]:.2f}, {target_position[2]:.2f})",
        color='blue')

# Set view angle similar to the image
ax.view_init(elev=20, azim=-40)

# Save the plot as PNG
output_path = '/results/robot_visualization.png'
plt.savefig(output_path, dpi=300, bbox_inches='tight')
print(f"Visualization saved to: {output_path}")

# Also save joint angles to a text file
with open('/results/joint_angles.txt', 'w') as f:
    f.write("Joint angles (radians):\n")
    for i, angle in enumerate(ik_solution[1:]):  # Skip the first element (base)
        f.write(f"Joint {i+1}: {angle:.6f}\n")
    f.write("\nTarget position: ({:.2f}, {:.2f}, {:.2f})\n".format(*target_position))
    f.write("Achieved position: ({:.2f}, {:.2f}, {:.2f})\n".format(*end_effector_position))

print("IK calculation and visualization completed successfully!")
EOF

# Make the Python script executable
chmod +x /code/robot_visualization/ik_visualization.py

# Debug log - Python script created
echo "Python script for IK calculation and visualization created"

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