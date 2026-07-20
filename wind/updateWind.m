function wind = updateWind( ...
    wind, simulationTime, config)
%UPDATEWIND Calculate steady wind, gusts, and filtered turbulence.
%
% The wind model is:
%
%   total wind =
%       constant mean wind
%       + sinusoidal gusts
%       + filtered random turbulence

    if ~config.wind.enabled

        wind.enabled = false;

        wind.meanVelocity = [0, 0, 0];
        wind.gustVelocity = [0, 0, 0];
        wind.turbulenceVelocity = [0, 0, 0];
        wind.totalVelocity = [0, 0, 0];

        wind.compensationVelocity = [0, 0, 0];

        wind.speed = 0;
        wind.directionDegrees = 0;

        return;
    end

    wind.enabled = true;

    dt = config.timeStep;

    %% Constant mean wind
    wind.meanVelocity = ...
        config.wind.meanVelocity;

    %% Periodic gust velocity
    angularFrequency = ...
        2*pi * config.wind.gustFrequency;

    wind.gustVelocity = ...
        config.wind.gustAmplitude .* ...
        sin( ...
            angularFrequency * simulationTime + ...
            config.wind.gustPhase);

    %% Generate raw turbulence sample
    rawTurbulence = ...
        config.wind.turbulenceStd .* ...
        randn(1, 3);

    %% First-order low-pass filtering
    filterCoefficient = ...
        dt / ...
        (config.wind.turbulenceTimeConstant + dt);

    wind.turbulenceVelocity = ...
        wind.turbulenceVelocity + ...
        filterCoefficient * ...
        (rawTurbulence - wind.turbulenceVelocity);

    %% Total atmospheric velocity
    wind.totalVelocity = ...
        wind.meanVelocity + ...
        wind.gustVelocity + ...
        wind.turbulenceVelocity;

    %% Wind compensation
    if config.wind.compensationEnabled

        wind.compensationVelocity = ...
            -config.wind.compensationGain * ...
            wind.totalVelocity;

        compensationSpeed = ...
            norm(wind.compensationVelocity);

        if compensationSpeed > ...
                config.wind.maxCompensationSpeed

            wind.compensationVelocity = ...
                wind.compensationVelocity / ...
                compensationSpeed * ...
                config.wind.maxCompensationSpeed;
        end

    else

        wind.compensationVelocity = ...
            [0, 0, 0];
    end

    %% Wind statistics
    wind.speed = ...
        norm(wind.totalVelocity);

    if wind.speed > 1e-6

        wind.directionDegrees = ...
            atan2d( ...
                wind.totalVelocity(2), ...
                wind.totalVelocity(1));

    else

        wind.directionDegrees = 0;
    end

    wind.maximumSpeedObserved = max( ...
        wind.maximumSpeedObserved, ...
        wind.speed);

    wind.updateCount = ...
        wind.updateCount + 1;

    wind.cumulativeWindSpeed = ...
        wind.cumulativeWindSpeed + ...
        wind.speed;

    wind.averageSpeed = ...
        wind.cumulativeWindSpeed / ...
        max(wind.updateCount, 1);
end