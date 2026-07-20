function occupancyGrid = initializeOccupancyMap(config)
%INITIALIZEOCCUPANCYMAP Create an initially unknown probability grid.
%
% Every grid cell begins with:
%
%   probability = 0.5
%   log-odds    = 0
%
% Probability meaning:
%   Near 0.0 = probably free
%   Near 0.5 = unknown
%   Near 1.0 = probably occupied

    %% Store map limits
    occupancyGrid.xLimits = ...
        config.world.xLimits;

    occupancyGrid.yLimits = ...
        config.world.yLimits;

    occupancyGrid.resolution = ...
        config.mapping.resolution;

    occupancyGrid.cellSize = ...
        1 / occupancyGrid.resolution;

    %% Calculate map dimensions
    mapWidthMetres = ...
        occupancyGrid.xLimits(2) - ...
        occupancyGrid.xLimits(1);

    mapHeightMetres = ...
        occupancyGrid.yLimits(2) - ...
        occupancyGrid.yLimits(1);

    occupancyGrid.numberOfColumns = ...
        ceil(mapWidthMetres * occupancyGrid.resolution);

    occupancyGrid.numberOfRows = ...
        ceil(mapHeightMetres * occupancyGrid.resolution);

    %% Initialize log-odds matrix
    occupancyGrid.logOdds = ...
        config.mapping.initialLogOdds * ...
        ones( ...
            occupancyGrid.numberOfRows, ...
            occupancyGrid.numberOfColumns);

    %% Create cell-center coordinates
    occupancyGrid.xCenters = ...
        occupancyGrid.xLimits(1) + ...
        ((1:occupancyGrid.numberOfColumns) - 0.5) * ...
        occupancyGrid.cellSize;

    occupancyGrid.yCenters = ...
        occupancyGrid.yLimits(1) + ...
        ((1:occupancyGrid.numberOfRows) - 0.5) * ...
        occupancyGrid.cellSize;

    %% Mapping statistics
    occupancyGrid.updateCount = 0;
    occupancyGrid.lastUpdateTime = -Inf;

    occupancyGrid.observedCellCount = 0;
    occupancyGrid.freeCellCount = 0;
    occupancyGrid.occupiedCellCount = 0;
    occupancyGrid.unknownCellCount = ...
        numel(occupancyGrid.logOdds);

    occupancyGrid.coveragePercent = 0;
end