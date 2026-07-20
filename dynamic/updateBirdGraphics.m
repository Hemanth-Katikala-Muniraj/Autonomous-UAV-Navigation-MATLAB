function updateBirdGraphics(graphics, bird)
%UPDATEBIRDGRAPHICS Update bird position, visibility, and wing motion.

    if bird.active

        graphics.transform.Visible = "on";
        graphics.label.Visible = "on";

    else

        graphics.transform.Visible = "off";
        graphics.label.Visible = "off";
        return;
    end

    translationMatrix = ...
        makehgtform("translate", bird.position);

    yawMatrix = ...
        makehgtform("zrotate", bird.yaw);

    graphics.transform.Matrix = ...
        translationMatrix * yawMatrix;

    %% Animate wing movement
    wingVerticalOffset = ...
        0.35 * sin(bird.flapAngle);

    set( ...
        graphics.leftWing, ...
        "ZData", ...
        [0, wingVerticalOffset, ...
        1.6 * wingVerticalOffset, 0]);

    set( ...
        graphics.rightWing, ...
        "ZData", ...
        [0, wingVerticalOffset, ...
        1.6 * wingVerticalOffset, 0]);

    %% Move label
    graphics.label.Position = [
        bird.position(1), ...
        bird.position(2), ...
        bird.position(3) + 0.60
    ];
end