function lidar = simulateLidar( ...
    drone, environment, bird, config)
%SIMULATELIDAR Simulate horizontal 360-degree LiDAR.
%
% The sensor detects:
%   1. Static rectangular buildings
%   2. A moving bird represented by a circular collision region
%
% hitSource values:
%   0 = no hit
%   1 = static building
%   2 = dynamic bird

    numberOfRays = config.lidar.numberOfRays;
    maximumRange = config.lidar.maxRange;
    minimumRange = config.lidar.minRange;

    relativeAngles = linspace( ...
        -config.lidar.fieldOfView/2, ...
         config.lidar.fieldOfView/2, ...
         numberOfRays + 1);

    relativeAngles(end) = [];

    worldAngles = ...
        relativeAngles + drone.yaw;

    ranges = ...
        maximumRange * ones(1, numberOfRays);

    hitDetected = ...
        false(1, numberOfRays);

    hitSource = ...
        zeros(1, numberOfRays);

    rayOrigin = drone.position(1:2);
    droneAltitude = drone.position(3);

    numberOfBuildings = ...
        size(environment.buildingCenters, 1);

    %% Process each LiDAR ray
    for rayIndex = 1:numberOfRays

        rayDirection = [
            cos(worldAngles(rayIndex)), ...
            sin(worldAngles(rayIndex))
        ];

        nearestDistance = maximumRange;
        nearestSource = 0;

        %% Static building intersections
        for buildingIndex = 1:numberOfBuildings

            center = ...
                environment.buildingCenters( ...
                buildingIndex, :);

            dimensions = ...
                environment.buildingDimensions( ...
                buildingIndex, :);

            buildingHeight = dimensions(3);

            if droneAltitude > buildingHeight
                continue;
            end

            halfLength = dimensions(1)/2;
            halfWidth = dimensions(2)/2;

            boxMinimum = [
                center(1) - halfLength, ...
                center(2) - halfWidth
            ];

            boxMaximum = [
                center(1) + halfLength, ...
                center(2) + halfWidth
            ];

            intersectionDistance = ...
                rayBoxIntersection2D( ...
                    rayOrigin, ...
                    rayDirection, ...
                    boxMinimum, ...
                    boxMaximum);

            if intersectionDistance >= minimumRange && ...
                    intersectionDistance < nearestDistance

                nearestDistance = intersectionDistance;
                nearestSource = 1;
            end
        end

        %% Dynamic bird intersection
        birdIsAtSensorHeight = ...
            bird.active && ...
            abs(bird.position(3) - droneAltitude) <= ...
            config.bird.lidarVerticalTolerance;

        if birdIsAtSensorHeight

            birdDistance = rayCircleIntersection2D( ...
                rayOrigin, ...
                rayDirection, ...
                bird.position(1:2), ...
                bird.radius);

            if birdDistance >= minimumRange && ...
                    birdDistance < nearestDistance

                nearestDistance = birdDistance;
                nearestSource = 2;
            end
        end

        %% Store nearest hit
        if nearestDistance < maximumRange

            hitDetected(rayIndex) = true;
            hitSource(rayIndex) = nearestSource;

            noisyDistance = ...
                nearestDistance + ...
                config.lidar.noiseStd * randn();

            ranges(rayIndex) = min( ...
                maximumRange, ...
                max(minimumRange, noisyDistance));
        end
    end

    %% Convert ranges into world-coordinate hit points
    hitPoints = zeros(numberOfRays, 3);

    for rayIndex = 1:numberOfRays

        hitPoints(rayIndex,:) = ...
            drone.position + [
                ranges(rayIndex) * ...
                cos(worldAngles(rayIndex)), ...
                ranges(rayIndex) * ...
                sin(worldAngles(rayIndex)), ...
                0
            ];
    end

    lidar.relativeAngles = relativeAngles;
    lidar.worldAngles = worldAngles;
    lidar.ranges = ranges;
    lidar.hitDetected = hitDetected;
    lidar.hitPoints = hitPoints;
    lidar.hitSource = hitSource;
end


function distance = rayCircleIntersection2D( ...
    rayOrigin, rayDirection, circleCenter, circleRadius)
%RAYCIRCLEINTERSECTION2D Calculate ray-circle intersection distance.

    originToCenter = ...
        rayOrigin - circleCenter;

    quadraticB = ...
        2 * dot(rayDirection, originToCenter);

    quadraticC = ...
        dot(originToCenter, originToCenter) - ...
        circleRadius^2;

    discriminant = ...
        quadraticB^2 - 4*quadraticC;

    if discriminant < 0

        distance = Inf;
        return;
    end

    squareRootDiscriminant = ...
        sqrt(discriminant);

    firstDistance = ...
        (-quadraticB - squareRootDiscriminant)/2;

    secondDistance = ...
        (-quadraticB + squareRootDiscriminant)/2;

    validDistances = [
        firstDistance, ...
        secondDistance
    ];

    validDistances = ...
        validDistances(validDistances >= 0);

    if isempty(validDistances)
        distance = Inf;
    else
        distance = min(validDistances);
    end
end