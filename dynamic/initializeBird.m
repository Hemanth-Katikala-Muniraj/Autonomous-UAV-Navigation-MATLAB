function bird = initializeBird(config)
%INITIALIZEBIRD Create the initial dynamic bird state.

    bird.position = config.bird.startPosition;

    bird.previousPosition = bird.position;

    pathVector = ...
        config.bird.endPosition - ...
        config.bird.startPosition;

    bird.pathLength = norm(pathVector);

    if bird.pathLength > 1e-6
        bird.direction = pathVector / bird.pathLength;
    else
        bird.direction = [0, 0, 0];
    end

    bird.velocity = ...
        config.bird.speed * bird.direction;

    bird.radius = config.bird.radius;

    bird.active = false;
    bird.complete = false;

    bird.progress = 0;
    bird.distanceTravelled = 0;

    bird.yaw = atan2( ...
        bird.direction(2), ...
        bird.direction(1));

    bird.flapAngle = 0;
end