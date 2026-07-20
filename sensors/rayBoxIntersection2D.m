function distance = rayBoxIntersection2D( ...
    rayOrigin, rayDirection, boxMinimum, boxMaximum)
%RAYBOXINTERSECTION2D Find where a 2D ray intersects a rectangle.
%
% Inputs:
%   rayOrigin     - Ray starting point [x y]
%   rayDirection  - Unit direction vector [dx dy]
%   boxMinimum    - Rectangle minimum corner [xmin ymin]
%   boxMaximum    - Rectangle maximum corner [xmax ymax]
%
% Output:
%   distance      - Distance from the ray origin to the first intersection.
%                   Returns Inf when the ray does not hit the rectangle.

    epsilon = 1e-9;

    inverseDirection = zeros(1, 2);

    for axisIndex = 1:2
        if abs(rayDirection(axisIndex)) < epsilon
            inverseDirection(axisIndex) = Inf;
        else
            inverseDirection(axisIndex) = ...
                1 / rayDirection(axisIndex);
        end
    end

    t1 = (boxMinimum - rayOrigin) .* inverseDirection;
    t2 = (boxMaximum - rayOrigin) .* inverseDirection;

    tMinimumPerAxis = min(t1, t2);
    tMaximumPerAxis = max(t1, t2);

    entryDistance = max(tMinimumPerAxis);
    exitDistance = min(tMaximumPerAxis);

    if exitDistance < 0 || entryDistance > exitDistance
        distance = Inf;
        return;
    end

    if entryDistance >= 0
        distance = entryDistance;
    else
        distance = exitDistance;
    end
end