%% Autonomous Drone MATLAB Project Validation
% Run this script from the project root before publishing the repository.

clc;

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(genpath(projectRoot));

fprintf("AUTONOMOUS DRONE PROJECT VALIDATION\n");
fprintf("Project root: %s\n\n", projectRoot);

requiredFolders = {
    "config"
    "drone"
    "navigation"
    "mapping"
    "visualization"
    "logging"
    "reporting"
    "wind"
};

requiredFunctions = {
    "simulationConfig"
    "initializeDrone"
    "updateDroneDynamics"
    "waypointController"
    "potentialFieldController"
    "refinedLandingController"
    "initializeWind"
    "updateWind"
    "initializeOccupancyMap"
    "updateOccupancyMap"
    "initializeFPVGraphics"
    "updateFPVGraphics"
    "initializeMissionRecorder"
    "recordMissionStep"
    "finalizeMissionRecorder"
    "generateMissionReportPlots"
};

requiredProducts = {
    "MATLAB"
    "UAV Toolbox"
    "Navigation Toolbox"
    "Robotics System Toolbox"
};

validationPassed = true;

fprintf("1. FOLDER CHECK\n");

for folderIndex = 1:numel(requiredFolders)

    folderPath = fullfile( ...
        projectRoot, ...
        requiredFolders{folderIndex});

    if isfolder(folderPath)

        fprintf("[FOUND]   %s\n", requiredFolders{folderIndex});

    else

        fprintf("[MISSING] %s\n", requiredFolders{folderIndex});
        validationPassed = false;
    end
end

fprintf("\n2. FUNCTION CHECK\n");

for functionIndex = 1:numel(requiredFunctions)

    functionName = requiredFunctions{functionIndex};

    functionPath = which(functionName);

    if ~isempty(functionPath)

        fprintf("[FOUND]   %-32s %s\n", ...
            functionName, functionPath);

    else

        fprintf("[MISSING] %s\n", functionName);
        validationPassed = false;
    end
end

fprintf("\n3. TOOLBOX CHECK\n");

installedProducts = ver;
installedNames = string({installedProducts.Name});

for productIndex = 1:numel(requiredProducts)

    productName = string(requiredProducts{productIndex});

    if any(installedNames == productName)

        fprintf("[FOUND]   %s\n", productName);

    else

        fprintf("[MISSING] %s\n", productName);
        validationPassed = false;
    end
end

fprintf("\n4. CONFIGURATION CHECK\n");

try

    config = simulationConfig();

    requiredFields = {
        "timeStep"
        "world"
        "drone"
        "mission"
        "landing"
        "lidar"
        "apf"
        "bird"
        "mapping"
        "wind"
        "fpv"
        "logging"
        "video"
    };

    for fieldIndex = 1:numel(requiredFields)

        fieldName = requiredFields{fieldIndex};

        if isfield(config, fieldName)

            fprintf("[FOUND]   config.%s\n", fieldName);

        else

            fprintf("[MISSING] config.%s\n", fieldName);
            validationPassed = false;
        end
    end

catch configError

    fprintf("[ERROR] simulationConfig failed: %s\n", ...
        configError.message);

    validationPassed = false;
end

fprintf("\n5. OUTPUT CHECK\n");

outputPaths = {
    fullfile(projectRoot, "output", "data", "missionTelemetry.csv")
    fullfile(projectRoot, "output", "data", "missionSummary.csv")
    fullfile(projectRoot, "output", "data", "missionData.mat")
    fullfile(projectRoot, "output", "video", "autonomousDroneMission.mp4")
    fullfile(projectRoot, "output", "plots")
};

for outputIndex = 1:numel(outputPaths)

    outputPath = outputPaths{outputIndex};

    if isfile(outputPath) || isfolder(outputPath)

        fprintf("[FOUND]   %s\n", outputPath);

    else

        fprintf("[OPTIONAL] Not generated yet: %s\n", outputPath);
    end
end

fprintf("\n");

if validationPassed

    fprintf("[SUCCESS] Project validation passed.\n");

else

    fprintf("[FAILED] Resolve the missing requirements above.\n");
end
