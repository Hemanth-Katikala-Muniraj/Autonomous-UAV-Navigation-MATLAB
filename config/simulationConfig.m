function config = simulationConfig()
%SIMULATIONCONFIG Store all simulation configuration parameters.
%
% Stage 9 landing-stability revision:
%   - Explicit landing-yaw target
%   - Rate-limited yaw alignment
%   - Yaw hold during descent, flare, and touchdown
%   - Minimum navigation speed before velocity-based yaw updates
%
% Existing features:
%   - Autonomous waypoint navigation
%   - Dynamic bird avoidance
%   - LiDAR and APF collision avoidance
%   - Occupancy-grid mapping
%   - Wind disturbance and compensation
%   - FPV camera
%   - Telemetry and MP4 recording
%   - Refined autonomous landing

    %% Simulation timing
    config.timeStep = 0.05;
    config.maxSimulationTime = 180;
    config.realTimePlayback = false;

    %% World dimensions
    config.world.xLimits = [0, 30];
    config.world.yLimits = [-6, 6];
    config.world.zLimits = [0, 10];

    %% Drone parameters
    config.drone.startPosition = [1, 0, 0];
    config.drone.takeoffAltitude = 3.5;

    config.drone.cruiseSpeed = 1.35;
    config.drone.maxSpeed = 2.00;
    config.drone.maxAcceleration = 1.80;
    config.drone.velocityResponseTime = 0.40;

    config.drone.radius = 0.35;

    % The drone follows its velocity direction only when its horizontal
    % speed is high enough to provide a reliable heading estimate.
    %
    % This prevents tiny wind-induced velocities from causing large yaw
    % changes while hovering or landing.
    config.drone.minimumYawUpdateSpeed = 0.25;

    % Maximum normal-flight yaw slew rate.
    config.drone.maximumNavigationYawRate = deg2rad(70);

    %% Mission parameters
    config.mission.goalPosition = [28, 0, 0];

    config.mission.waypointTolerance = 0.60;

    config.mission.waypoints = [
         1, 0, 3.5
         5, 0, 3.5
         9, 0, 4.0
        16, 0, 4.0
        20, 0, 3.8
        25, 0, 3.2
        28, 0, 3.0
    ];

    %% Refined landing parameters

    % Altitude at which alignment above the landing pad occurs.
    config.landing.approachAltitude = 2.50;

    % Altitude at which the final flare begins.
    config.landing.flareAltitude = 0.70;

    % Height treated as physical ground contact.
    config.landing.touchdownHeight = 0.08;

    %% Landing position tolerances
    config.landing.approachHorizontalTolerance = 0.30;
    config.landing.descentHorizontalTolerance = 0.25;
    config.landing.touchdownHorizontalTolerance = 0.15;

    config.landing.approachVerticalTolerance = 0.20;
    config.landing.flareVerticalTolerance = 0.10;
    config.landing.touchdownVerticalTolerance = 0.04;

    %% Landing speed limits
    config.landing.approachHorizontalSpeed = 0.70;
    config.landing.descentHorizontalSpeed = 0.35;
    config.landing.flareHorizontalSpeed = 0.16;

    config.landing.descentSpeed = 0.42;
    config.landing.flareDescentSpeed = 0.14;

    %% Landing controller
    config.landing.positionGain = 0.75;

    %% Touchdown verification
    config.landing.touchdownVerificationTime = 1.25;

    config.landing.maximumTouchdownSpeed = 0.18;
    config.landing.maximumTouchdownVerticalSpeed = 0.10;

    %% Landing yaw control

    % Desired final heading in radians.
    %
    % 0 radians means facing world +X, along the road.
    config.landing.targetYaw = deg2rad(0);

    % The drone aligns gradually instead of rotating instantly.
    config.landing.maximumYawRate = deg2rad(35);

    % Yaw error must be within this tolerance before controlled descent.
    config.landing.yawTolerance = deg2rad(3);

    % Proportional yaw-controller gain.
    config.landing.yawGain = 1.8;

    % During approach, the drone must remain aligned for this duration
    % before transitioning into descent.
    config.landing.yawStabilityTime = 0.40;

    %% LiDAR parameters
    config.lidar.maxRange = 7.0;
    config.lidar.minRange = 0.20;
    config.lidar.numberOfRays = 180;
    config.lidar.fieldOfView = 2*pi;
    config.lidar.noiseStd = 0.015;

    %% Artificial Potential Field parameters
    config.apf.enabled = true;

    config.apf.influenceDistance = 4.00;
    config.apf.safetyDistance = 1.00;
    config.apf.emergencyDistance = 0.65;

    config.apf.corridorHalfWidth = 1.40;
    config.apf.nearCorridorHalfWidth = 1.75;
    config.apf.nearObstacleDistance = 1.80;
    config.apf.minimumForwardProjection = 0.05;

    config.apf.repulsiveGain = 1.20;
    config.apf.tangentialGain = 1.45;

    config.apf.maxRepulsiveSpeed = 1.30;
    config.apf.maxTangentialSpeed = 1.25;
    config.apf.maxCommandSpeed = 1.75;

    config.apf.minimumForwardSpeed = 0.25;
    config.apf.emergencyForwardScale = 0.08;
    config.apf.preferredTurnDirection = -1;

    %% Dynamic bird parameters
    config.bird.enabled = true;
    config.bird.startTime = 7.0;

    config.bird.startPosition = [12.5, -5.0, 4.0];
    config.bird.endPosition = [12.5, 5.0, 4.0];

    config.bird.speed = 1.35;
    config.bird.radius = 0.50;
    config.bird.lidarVerticalTolerance = 0.70;

    config.bird.flapFrequency = 3.0;
    config.bird.maximumWingAngle = deg2rad(28);

    %% Occupancy-grid mapping parameters
    config.mapping.resolution = 4;
    config.mapping.updateInterval = 0.15;

    config.mapping.initialLogOdds = 0.0;
    config.mapping.freeLogOddsIncrement = -0.38;
    config.mapping.occupiedLogOddsIncrement = 0.90;

    config.mapping.minimumLogOdds = -4.0;
    config.mapping.maximumLogOdds = 4.0;

    config.mapping.freeThreshold = 0.35;
    config.mapping.occupiedThreshold = 0.65;

    config.mapping.samplesPerCell = 1.5;
    config.mapping.includeDynamicObstacles = false;

    %% Wind disturbance parameters
    config.wind.enabled = true;

    config.wind.meanVelocity = [0.05, 0.32, 0.00];

    config.wind.gustAmplitude = [0.10, 0.28, 0.06];
    config.wind.gustFrequency = [0.21, 0.37, 0.16];
    config.wind.gustPhase = [0.0, pi/3, pi/2];

    config.wind.turbulenceStd = [0.035, 0.060, 0.020];
    config.wind.turbulenceTimeConstant = 0.65;

    config.wind.compensationEnabled = true;
    config.wind.compensationGain = 0.88;
    config.wind.maxCompensationSpeed = 0.75;

    config.wind.arrowScale = 3.0;

    %% FPV camera parameters
    config.fpv.enabled = true;

    config.fpv.horizontalFOV = deg2rad(90);
    config.fpv.verticalFOV = deg2rad(60);

    config.fpv.maximumViewDistance = 18.0;

    config.fpv.cameraForwardOffset = 0.25;
    config.fpv.cameraVerticalOffset = -0.05;

    config.fpv.screenXLimits = [-1, 1];
    config.fpv.screenYLimits = [-1, 1];

    config.fpv.cautionDistance = 4.0;
    config.fpv.dangerDistance = 2.0;

    %% Telemetry logging parameters
    config.logging.enabled = true;
    config.logging.sampleInterval = 0.10;

    config.logging.csvRelativeFile = ...
        fullfile("output", "data", "missionTelemetry.csv");

    config.logging.summaryRelativeFile = ...
        fullfile("output", "data", "missionSummary.csv");

    config.logging.matRelativeFile = ...
        fullfile("output", "data", "missionData.mat");

    %% Video recording parameters
    config.video.enabled = true;
    config.video.profile = "MPEG-4";

    config.video.frameRate = 20;
    config.video.quality = 92;

    config.video.captureInterval = ...
        1 / config.video.frameRate;

    config.video.relativeFile = ...
        fullfile( ...
            "output", ...
            "video", ...
            "autonomousDroneMission.mp4");
end