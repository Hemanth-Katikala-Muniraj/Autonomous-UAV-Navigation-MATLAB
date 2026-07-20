function drone = initializeDrone(config)
%INITIALIZEDRONE Create the initial drone state.
%
% The state contains:
%   - Position and velocity
%   - Orientation
%   - Physical properties
%   - Mission progress
%   - Explicit yaw-control state
%   - Refined landing state
%   - Flight statistics

    %% Position
    drone.position = ...
        config.drone.startPosition;

    drone.previousPosition = ...
        drone.position;

    %% Velocity
    drone.airVelocity = [0, 0, 0];
    drone.windVelocity = [0, 0, 0];
    drone.velocity = [0, 0, 0];
    drone.acceleration = [0, 0, 0];

    %% Orientation
    drone.roll = 0;
    drone.pitch = 0;
    drone.yaw = 0;

    %% Explicit yaw-control state
    drone.yawControlActive = false;

    drone.commandedYaw = ...
        drone.yaw;

    drone.yawError = 0;
    drone.commandedYawRate = 0;

    %% Physical properties
    drone.radius = ...
        config.drone.radius;

    %% Mission progress
    drone.currentWaypointIndex = 1;
    drone.missionState = "TAKEOFF";
    drone.missionComplete = false;

    %% Landing state
    drone.landingStartTime = NaN;
    drone.landingPhaseStartTime = NaN;
    drone.touchdownStartTime = NaN;

    drone.yawAlignedStartTime = NaN;

    drone.touchdownDetected = false;
    drone.touchdownVerified = false;
    drone.groundLockActive = false;

    drone.landingPhase = "NOT_STARTED";

    drone.touchdownPosition = [NaN, NaN, NaN];
    drone.touchdownSpeed = NaN;
    drone.touchdownVerticalSpeed = NaN;

    %% Mission statistics
    drone.distanceTravelled = 0;

    drone.maximumCrossTrackError = 0;
    drone.cumulativeCrossTrackError = 0;
    drone.crossTrackSampleCount = 0;
    drone.averageCrossTrackError = 0;
end