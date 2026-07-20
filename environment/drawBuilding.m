function buildingHandle = drawBuilding(ax, center, dimensions, faceColor)
%DRAWBUILDING Draw a rectangular 3D building.
%
% Inputs:
%   ax         - Target axes
%   center     - [x y] center of building
%   dimensions - [length width height]
%   faceColor  - RGB color, for example [0.7 0.4 0.2]

    arguments
        ax
        center (1,2) double
        dimensions (1,3) double
        faceColor (1,3) double
    end

    lengthX = dimensions(1);
    widthY  = dimensions(2);
    heightZ = dimensions(3);

    xMin = center(1) - lengthX/2;
    xMax = center(1) + lengthX/2;

    yMin = center(2) - widthY/2;
    yMax = center(2) + widthY/2;

    zMin = 0;
    zMax = heightZ;

    vertices = [
        xMin yMin zMin
        xMax yMin zMin
        xMax yMax zMin
        xMin yMax zMin
        xMin yMin zMax
        xMax yMin zMax
        xMax yMax zMax
        xMin yMax zMax
    ];

    faces = [
        1 2 3 4
        5 8 7 6
        1 5 6 2
        2 6 7 3
        3 7 8 4
        4 8 5 1
    ];

    buildingHandle = patch( ...
        ax, ...
        "Vertices", vertices, ...
        "Faces", faces, ...
        "FaceColor", faceColor, ...
        "FaceAlpha", 0.92, ...
        "EdgeColor", [0.15 0.15 0.15], ...
        "LineWidth", 0.8);
end