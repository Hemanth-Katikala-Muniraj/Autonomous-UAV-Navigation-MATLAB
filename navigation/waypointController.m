function desiredVelocity = waypointController( ...
    currentPosition, targetPosition, config)
%WAYPOINTCONTROLLER Calculate the desired velocity toward a target.
%
% Inputs:
%   currentPosition - Current drone position [x y z]
%   targetPosition  - Desired target position [x y z]
%   config          - Simulation configuration
%
% Output:
%   desiredVelocity - Requested velocity [vx vy vz]

    positionError = targetPosition - currentPosition;
    distanceToTarget = norm(positionError);

    if distanceToTarget < 1e-6
        desiredVelocity = [0, 0, 0];
        return;
    end

    directionToTarget = positionError / distanceToTarget;

    % Slow down while approaching the waypoint.
    slowingDistance = 1.5;

    speedScale = min( ...
        1.0, ...
        distanceToTarget / slowingDistance);

    commandedSpeed = ...
        config.drone.cruiseSpeed * speedScale;

    % Prevent the vehicle from becoming unnecessarily slow.
    if distanceToTarget > config.mission.waypointTolerance
        commandedSpeed = max(commandedSpeed, 0.25);
    end

    desiredVelocity = ...
        directionToTarget * commandedSpeed;
end