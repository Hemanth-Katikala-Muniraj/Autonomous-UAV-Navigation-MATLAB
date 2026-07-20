# Interview Guide

## 90-Second Project Explanation

I developed an autonomous UAV simulation in MATLAB to demonstrate the integration of perception, planning, control, mapping, and mission validation. The drone performs autonomous takeoff, follows a multi-waypoint route through a 3D urban environment, uses a simulated 360-degree LiDAR to detect buildings and a moving bird, and applies an Artificial Potential Field controller for real-time obstacle avoidance. I also implemented a probabilistic occupancy grid using log-odds updates, where free space and static obstacle endpoints are accumulated while dynamic bird detections are excluded from the permanent map.

To make the simulation more realistic, I added steady wind, sinusoidal gusts, filtered turbulence, and feedforward wind compensation. I built an FPV camera with a HUD, target projection, obstacle warnings, and corrected camera-frame orientation. For landing, I created a state machine with approach alignment, yaw stabilization, controlled descent, flare, touchdown verification, and ground lock. In the final run, the system completed the mission with about 0.80 meters minimum bird clearance, 92.7% map coverage, and a touchdown vertical speed near 0.02 meters per second. The project also exports CSV and MAT telemetry, records the dashboard as an MP4, and generates automated performance plots.

## High-Potential Questions

### Why did you use APF?

APF is computationally lightweight and works well for demonstrating reactive obstacle avoidance. I combined repulsive and tangential components so the drone not only moved away from an obstacle but also selected a side to pass it. I added safety and emergency thresholds to reduce forward motion when clearance became critical.

### What technical issue did you face?

One major issue occurred during landing. Yaw was originally estimated from instantaneous horizontal velocity. Near hover, tiny wind-induced velocity changes caused large heading jumps and visible spinning. I fixed this by introducing a minimum speed threshold for navigation-based yaw updates and explicit rate-limited yaw control during landing.

### How did you validate bird avoidance?

I logged LiDAR bird detections, APF activation steps, drone-to-bird surface clearance, FPV visibility, and the final flight path. The final run recorded roughly 63 bird-avoidance activations and maintained approximately 0.80 meters of minimum clearance.

### How does the occupancy map work?

I implemented a log-odds grid. For each LiDAR ray, cells before the endpoint receive a free-space update. Static obstacle endpoints receive an occupied update. The dynamic bird is excluded from permanent occupancy updates so it does not leave a false obstacle trail.

### Why is this not full SLAM?

The project performs occupancy mapping using known simulated drone pose. It does not jointly estimate pose and map uncertainty. A full SLAM implementation would include localization uncertainty, scan matching, loop closure, and state estimation.

### How did you model wind?

The wind model contains a constant mean component, sinusoidal gusts with independent frequencies and phases, and filtered random turbulence. Feedforward compensation subtracts a scaled wind estimate from the required air-relative velocity.

### How is landing controlled?

The landing controller is a state machine. The drone first aligns above the landing point and reaches the target yaw. It then descends at a limited rate, enters a low-speed flare, verifies horizontal position, altitude, yaw, and velocity thresholds, and finally holds ground lock for a fixed verification time.

### What would you improve next?

I would add global planning with A* or RRT*, trajectory prediction for moving obstacles, a nonlinear or MPC controller, an EKF for state estimation, and ROS 2 integration for modular deployment.
