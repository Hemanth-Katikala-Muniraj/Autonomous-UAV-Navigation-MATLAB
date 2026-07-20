function recorder = initializeMissionRecorder(config)
%INITIALIZEMISSIONRECORDER Initialize telemetry and video recording.
%
% The recorder stores:
%   - Time-series telemetry arrays
%   - Logging and video timing
%   - Output file paths
%   - VideoWriter state

    %% Validate project root
    if ~isfield(config, "projectRoot") || ...
            strlength(string(config.projectRoot)) == 0

        error( ...
            "MissionRecorder:MissingProjectRoot", ...
            "config.projectRoot must be set by main.m.");
    end

    projectRoot = string(config.projectRoot);

    %% Resolve output paths
    recorder.telemetryFile = fullfile( ...
        projectRoot, ...
        config.logging.csvRelativeFile);

    recorder.summaryFile = fullfile( ...
        projectRoot, ...
        config.logging.summaryRelativeFile);

    recorder.matFile = fullfile( ...
        projectRoot, ...
        config.logging.matRelativeFile);

    recorder.videoFile = fullfile( ...
        projectRoot, ...
        config.video.relativeFile);

    %% Create output directories
    telemetryDirectory = fileparts(recorder.telemetryFile);
    videoDirectory = fileparts(recorder.videoFile);

    if ~isfolder(telemetryDirectory)
        mkdir(telemetryDirectory);
    end

    if ~isfolder(videoDirectory)
        mkdir(videoDirectory);
    end

    %% Recorder state
    recorder.loggingEnabled = config.logging.enabled;
    recorder.videoEnabled = config.video.enabled;

    recorder.nextLogTime = 0;
    recorder.nextVideoTime = 0;

    recorder.loggedSampleCount = 0;
    recorder.videoFrameCount = 0;

    recorder.videoWriter = [];
    recorder.videoFailureMessage = "";

    %% Initialize telemetry arrays
    recorder.data.Time = zeros(0,1);
    recorder.data.MissionState = strings(0,1);
    recorder.data.WaypointIndex = zeros(0,1);

    recorder.data.PositionX = zeros(0,1);
    recorder.data.PositionY = zeros(0,1);
    recorder.data.PositionZ = zeros(0,1);

    recorder.data.GroundVelocityX = zeros(0,1);
    recorder.data.GroundVelocityY = zeros(0,1);
    recorder.data.GroundVelocityZ = zeros(0,1);
    recorder.data.GroundSpeed = zeros(0,1);

    recorder.data.AirVelocityX = zeros(0,1);
    recorder.data.AirVelocityY = zeros(0,1);
    recorder.data.AirVelocityZ = zeros(0,1);
    recorder.data.AirSpeed = zeros(0,1);

    recorder.data.YawDegrees = zeros(0,1);
    recorder.data.PitchDegrees = zeros(0,1);
    recorder.data.RollDegrees = zeros(0,1);

    recorder.data.TargetDistance = zeros(0,1);
    recorder.data.DistanceTravelled = zeros(0,1);

    recorder.data.WindX = zeros(0,1);
    recorder.data.WindY = zeros(0,1);
    recorder.data.WindZ = zeros(0,1);
    recorder.data.WindSpeed = zeros(0,1);

    recorder.data.BirdActive = false(0,1);
    recorder.data.BirdPositionX = zeros(0,1);
    recorder.data.BirdPositionY = zeros(0,1);
    recorder.data.BirdPositionZ = zeros(0,1);
    recorder.data.BirdDistance = zeros(0,1);
    recorder.data.BirdClearance = zeros(0,1);
    recorder.data.BirdLidarHits = zeros(0,1);

    recorder.data.APFAvoidanceActive = false(0,1);
    recorder.data.APFEmergencyActive = false(0,1);
    recorder.data.APFObstacleCount = zeros(0,1);
    recorder.data.RepulsiveSpeed = zeros(0,1);
    recorder.data.TangentialSpeed = zeros(0,1);

    recorder.data.MapCoveragePercent = zeros(0,1);
    recorder.data.MapFreeCells = zeros(0,1);
    recorder.data.MapOccupiedCells = zeros(0,1);
    recorder.data.MapUpdateCount = zeros(0,1);

    recorder.data.FPVTargetVisible = false(0,1);
    recorder.data.FPVBirdVisible = false(0,1);
    recorder.data.FPVForwardObstacleDistance = zeros(0,1);

    %% Initialize video writer
    if recorder.videoEnabled

        try
            recorder.videoWriter = VideoWriter( ...
                char(recorder.videoFile), ...
                char(config.video.profile));

            recorder.videoWriter.FrameRate = ...
                config.video.frameRate;

            if isprop(recorder.videoWriter, "Quality")
                recorder.videoWriter.Quality = ...
                    config.video.quality;
            end

            open(recorder.videoWriter);

            fprintf( ...
                "Video recording initialized:\n%s\n", ...
                recorder.videoFile);

        catch videoError

            recorder.videoEnabled = false;

            recorder.videoFailureMessage = ...
                string(videoError.message);

            warning( ...
                "MissionRecorder:VideoInitializationFailed", ...
                "Video recording was disabled: %s", ...
                videoError.message);
        end
    end

    if recorder.loggingEnabled

        fprintf( ...
            "Telemetry logging initialized:\n%s\n", ...
            recorder.telemetryFile);
    end
end