function [commandVelocity, avoidance] = potentialFieldController( ...
    nominalVelocity, lidar, drone, config)
%POTENTIALFIELDCONTROLLER Perform LiDAR-based obstacle avoidance.
%
% Inputs:
%   nominalVelocity - Velocity requested by waypoint navigation
%   lidar           - Current LiDAR scan structure
%   drone           - Current drone state
%   config          - Complete simulation configuration
%
% Outputs:
%   commandVelocity - Final velocity after obstacle avoidance
%   avoidance       - Diagnostic information for telemetry
%
% The controller combines:
%
%   1. Forward waypoint motion
%   2. Repulsive motion away from blocking obstacles
%   3. Tangential motion around blocking obstacles
%
% Unlike a basic APF controller, this implementation uses a forward
% collision corridor. Obstacles beside or behind the intended route
% are ignored unless they are dangerously close.

    %% Initialize diagnostic output
    avoidance.active = false;
    avoidance.emergencyActive = false;

    avoidance.repulsiveVelocity = [0, 0, 0];
    avoidance.tangentialVelocity = [0, 0, 0];
    avoidance.totalAvoidanceVelocity = [0, 0, 0];

    avoidance.nearestObstacleDistance = Inf;
    avoidance.obstacleCount = 0;

    avoidance.leftObstacleWeight = 0;
    avoidance.rightObstacleWeight = 0;

    %% Return immediately when APF is disabled
    if ~config.apf.enabled
        commandVelocity = nominalVelocity;
        return;
    end

    %% Determine intended horizontal travel direction
    nominalHorizontalVelocity = nominalVelocity(1:2);
    nominalHorizontalSpeed = norm(nominalHorizontalVelocity);

    if nominalHorizontalSpeed > 1e-6

        travelDirection = ...
            nominalHorizontalVelocity / nominalHorizontalSpeed;

    else

        travelDirection = [
            cos(drone.yaw), ...
            sin(drone.yaw)
        ];
    end

    %% Direction perpendicular to travel
    leftDirection = [
        -travelDirection(2), ...
         travelDirection(1)
    ];

    rightDirection = -leftDirection;

    %% Extract valid LiDAR detections
    validIndices = find(lidar.hitDetected);

    if isempty(validIndices)
        commandVelocity = nominalVelocity;
        return;
    end

    %% Controller accumulators
    repulsiveXY = [0, 0];

    blockingObstacleWeight = 0;

    nearestBlockingDistance = Inf;

    influenceDistance = ...
        config.apf.influenceDistance;

    safetyDistance = ...
        config.apf.safetyDistance;

    %% Process each LiDAR detection
    for detectionIndex = validIndices

        obstacleDistance = ...
            lidar.ranges(detectionIndex);

        if obstacleDistance > influenceDistance
            continue;
        end

        %% Vector from drone to obstacle
        obstacleDirection = [
            cos(lidar.worldAngles(detectionIndex)), ...
            sin(lidar.worldAngles(detectionIndex))
        ];

        obstacleVector = ...
            obstacleDistance * obstacleDirection;

        %% Decompose obstacle location relative to intended travel
        forwardProjection = dot( ...
            obstacleVector, ...
            travelDirection);

        lateralProjection = dot( ...
            obstacleVector, ...
            leftDirection);

        lateralDistance = abs(lateralProjection);

        %% Select appropriate collision corridor width
        if obstacleDistance < ...
                config.apf.nearObstacleDistance

            corridorHalfWidth = ...
                config.apf.nearCorridorHalfWidth;

        else

            corridorHalfWidth = ...
                config.apf.corridorHalfWidth;
        end

        %% Determine whether obstacle can block the current path
        obstacleInForwardCorridor = ...
            forwardProjection > ...
            config.apf.minimumForwardProjection && ...
            lateralDistance < corridorHalfWidth;

        obstacleIsEmergency = ...
            obstacleDistance < ...
            config.apf.emergencyDistance;

        % Ignore obstacles that are beside or behind the planned motion,
        % unless they are inside the emergency distance.
        if ~obstacleInForwardCorridor && ...
                ~obstacleIsEmergency

            continue;
        end

        avoidance.obstacleCount = ...
            avoidance.obstacleCount + 1;

        avoidance.nearestObstacleDistance = min( ...
            avoidance.nearestObstacleDistance, ...
            obstacleDistance);

        nearestBlockingDistance = min( ...
            nearestBlockingDistance, ...
            obstacleDistance);

        %% Compute obstacle proximity
        distanceDenominator = max( ...
            influenceDistance - safetyDistance, ...
            1e-6);

        proximity = ...
            (influenceDistance - obstacleDistance) / ...
            distanceDenominator;

        proximity = max(0, min(1, proximity));

        %% Increase repulsion within safety distance
        if obstacleDistance < safetyDistance

            safetyViolation = ...
                (safetyDistance - obstacleDistance) / ...
                max(safetyDistance, 1e-6);

            proximity = ...
                1 + 2.5 * safetyViolation;
        end

        %% Increase importance for obstacles near path center
        corridorCenterWeight = ...
            1 - min(1, lateralDistance / corridorHalfWidth);

        obstacleWeight = ...
            proximity * ...
            (0.35 + 0.65 * corridorCenterWeight);

        blockingObstacleWeight = ...
            blockingObstacleWeight + obstacleWeight;

        %% Repulsive direction points away from obstacle
        awayDirection = -obstacleDirection;

        repulsiveMagnitude = ...
            config.apf.repulsiveGain * ...
            obstacleWeight^2;

        repulsiveXY = ...
            repulsiveXY + ...
            repulsiveMagnitude * awayDirection;

        %% Determine which side contains the obstacle
        if lateralProjection >= 0

            avoidance.leftObstacleWeight = ...
                avoidance.leftObstacleWeight + ...
                obstacleWeight;

        else

            avoidance.rightObstacleWeight = ...
                avoidance.rightObstacleWeight + ...
                obstacleWeight;
        end
    end

    %% Return nominal velocity if no blocking obstacles were found
    if avoidance.obstacleCount == 0
        commandVelocity = nominalVelocity;
        return;
    end

    avoidance.active = true;

    %% Normalize accumulated repulsive contribution
    repulsiveXY = ...
        repulsiveXY / ...
        max(blockingObstacleWeight, 1e-6);

    %% Limit repulsive speed
    repulsiveSpeed = norm(repulsiveXY);

    if repulsiveSpeed > ...
            config.apf.maxRepulsiveSpeed

        repulsiveXY = ...
            repulsiveXY / repulsiveSpeed * ...
            config.apf.maxRepulsiveSpeed;
    end

    %% Select tangential escape direction
    %
    % Obstacles on the left cause a right turn.
    % Obstacles on the right cause a left turn.
    if avoidance.leftObstacleWeight > ...
            avoidance.rightObstacleWeight

        selectedTangent = rightDirection;

    elseif avoidance.rightObstacleWeight > ...
            avoidance.leftObstacleWeight

        selectedTangent = leftDirection;

    else

        if config.apf.preferredTurnDirection >= 0
            selectedTangent = leftDirection;
        else
            selectedTangent = rightDirection;
        end
    end

    %% Tangential strength increases as obstacle distance decreases
    tangentProximity = ...
        (influenceDistance - nearestBlockingDistance) / ...
        max(influenceDistance - safetyDistance, 1e-6);

    tangentProximity = ...
        max(0, min(1, tangentProximity));

    tangentialSpeed = ...
        config.apf.tangentialGain * ...
        tangentProximity;

    tangentialSpeed = min( ...
        tangentialSpeed, ...
        config.apf.maxTangentialSpeed);

    tangentialXY = ...
        tangentialSpeed * selectedTangent;

    %% Emergency behavior
    adjustedNominalVelocity = nominalVelocity;

    if nearestBlockingDistance < ...
            config.apf.emergencyDistance

        avoidance.emergencyActive = true;

        adjustedNominalVelocity(1:2) = ...
            adjustedNominalVelocity(1:2) * ...
            config.apf.emergencyForwardScale;

        emergencyMultiplier = ...
            config.apf.emergencyDistance / ...
            max(nearestBlockingDistance, 0.10);

        repulsiveXY = ...
            repulsiveXY * emergencyMultiplier;

        repulsiveSpeed = norm(repulsiveXY);

        if repulsiveSpeed > ...
                config.apf.maxRepulsiveSpeed

            repulsiveXY = ...
                repulsiveXY / repulsiveSpeed * ...
                config.apf.maxRepulsiveSpeed;
        end

    else

        %% Preserve forward progress during normal avoidance
        existingForwardSpeed = dot( ...
            adjustedNominalVelocity(1:2), ...
            travelDirection);

        if existingForwardSpeed < ...
                config.apf.minimumForwardSpeed

            forwardCorrection = ...
                config.apf.minimumForwardSpeed - ...
                existingForwardSpeed;

            adjustedNominalVelocity(1:2) = ...
                adjustedNominalVelocity(1:2) + ...
                forwardCorrection * travelDirection;
        end
    end

    %% Store diagnostic vectors
    avoidance.repulsiveVelocity = [
        repulsiveXY, ...
        0
    ];

    avoidance.tangentialVelocity = [
        tangentialXY, ...
        0
    ];

    avoidance.totalAvoidanceVelocity = ...
        avoidance.repulsiveVelocity + ...
        avoidance.tangentialVelocity;

    %% Combine nominal and avoidance commands
    commandVelocity = ...
        adjustedNominalVelocity + ...
        avoidance.totalAvoidanceVelocity;

    %% Preserve waypoint altitude control
    commandVelocity(3) = ...
        nominalVelocity(3);

    %% Ensure some progress remains toward the target
    if ~avoidance.emergencyActive

        commandForwardSpeed = dot( ...
            commandVelocity(1:2), ...
            travelDirection);

        if commandForwardSpeed < ...
                config.apf.minimumForwardSpeed

            requiredCorrection = ...
                config.apf.minimumForwardSpeed - ...
                commandForwardSpeed;

            commandVelocity(1:2) = ...
                commandVelocity(1:2) + ...
                requiredCorrection * travelDirection;
        end
    end

    %% Limit final velocity command
    commandSpeed = norm(commandVelocity);

    if commandSpeed > ...
            config.apf.maxCommandSpeed

        commandVelocity = ...
            commandVelocity / commandSpeed * ...
            config.apf.maxCommandSpeed;
    end
end