function bird = updateBird(bird, simulationTime, config)
%UPDATEBIRD Move the bird from its start point to its end point.

    bird.previousPosition = bird.position;

    if ~config.bird.enabled

        bird.active = false;
        bird.complete = true;
        return;
    end

    if simulationTime < config.bird.startTime

        bird.position = config.bird.startPosition;
        bird.active = false;
        bird.complete = false;
        bird.progress = 0;
        return;
    end

    elapsedFlightTime = ...
        simulationTime - config.bird.startTime;

    commandedDistance = ...
        config.bird.speed * elapsedFlightTime;

    bird.progress = min( ...
        commandedDistance / max(bird.pathLength, 1e-6), ...
        1.0);

    bird.position = ...
        config.bird.startPosition + ...
        bird.progress * ...
        (config.bird.endPosition - ...
        config.bird.startPosition);

    bird.distanceTravelled = ...
        norm( ...
            bird.position - ...
            config.bird.startPosition);

    if bird.progress >= 1.0

        bird.active = false;
        bird.complete = true;
        bird.velocity = [0, 0, 0];

    else

        bird.active = true;
        bird.complete = false;

        bird.velocity = ...
            config.bird.speed * bird.direction;
    end

    bird.flapAngle = ...
        config.bird.maximumWingAngle * ...
        sin( ...
            2*pi * ...
            config.bird.flapFrequency * ...
            elapsedFlightTime);
end