# Robot Visualization and Inverse Kinematics

This project provides a Docker container for visualizing a robot URDF model and calculating inverse kinematics without using MATLAB. It uses ROS Noetic and Python libraries to generate a 3D visualization and calculate joint angles for a given end-effector position.

## Features

- Loads a custom robot URDF with STL meshes
- Calculates inverse kinematics for a target end-effector position
- Generates a 3D visualization of the robot
- Outputs joint angles and achieved position

## Requirements

- Docker
- Code Ocean environment (or similar)

## Input Files

Place the following files in the `/data` directory:

- `R7X_stl_v4.urdf`: The URDF file describing the robot
- `meshes/*.stl`: STL mesh files referenced in the URDF

## Output Files

The container generates the following output files in the `/results` directory:

- `robot_visualization.png`: A 3D visualization of the robot with the target position
- `joint_angles.txt`: The calculated joint angles and position information

## How It Works

1. The Docker container installs ROS Noetic and necessary Python dependencies
2. The run script copies the URDF and mesh files to the appropriate locations
3. A Python script loads the URDF, calculates inverse kinematics, and generates a visualization
4. The visualization and joint angles are saved to the output directory

## Customization

To change the target position, modify the `target_position` variable in the `run.sh` script.

## Troubleshooting

If you encounter issues with the visualization, check that:
- All STL files referenced in the URDF are present in the meshes directory
- The URDF file is valid and properly formatted
- The target position is reachable by the robot 