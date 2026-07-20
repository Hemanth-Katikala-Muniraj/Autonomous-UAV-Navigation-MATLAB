function wind = initializeWind(config)
%INITIALIZEWIND Create the initial atmospheric disturbance state.
%
% Wind contains three components:
%
%   meanVelocity
%   gustVelocity
%   turbulenceVelocity
%
% The total wind velocity is their sum.

    wind.enabled = config.wind.enabled;

    wind.meanVelocity = ...
        config.wind.meanVelocity;

    wind.gustVelocity = ...
        [0, 0, 0];

    wind.turbulenceVelocity = ...
        [0, 0, 0];

    wind.totalVelocity = ...
        wind.meanVelocity;

    wind.compensationVelocity = ...
        [0, 0, 0];

    wind.speed = ...
        norm(wind.totalVelocity);

    wind.directionDegrees = ...
        atan2d( ...
            wind.totalVelocity(2), ...
            wind.totalVelocity(1));

    wind.maximumSpeedObserved = ...
        wind.speed;

    wind.cumulativeWindSpeed = 0;
    wind.updateCount = 0;
    wind.averageSpeed = 0;
end