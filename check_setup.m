%% MATLAB UAV Project - Installation Check

clc;
clear;
close all;

fprintf("MATLAB Version: %s\n", version);

requiredProducts = {
    "MATLAB"
    "UAV Toolbox"
    "Navigation Toolbox"
    "Robotics System Toolbox"
};

installedProducts = ver;
installedNames = string({installedProducts.Name});

fprintf("\nInstalled product check:\n");
fprintf("-------------------------------------------\n");

for i = 1:numel(requiredProducts)
    productName = requiredProducts{i};

    if any(strcmpi(installedNames, productName))
        fprintf("[FOUND]   %s\n", productName);
    else
        fprintf("[MISSING] %s\n", productName);
    end
end

fprintf("-------------------------------------------\n");

% Test basic graphics
try
    figure("Name", "MATLAB Graphics Test");
    plot3([0 1], [0 1], [0 1], "LineWidth", 2);
    grid on;
    xlabel("X");
    ylabel("Y");
    zlabel("Z");
    title("MATLAB 3D Graphics Test");
    view(3);

    fprintf("\n[SUCCESS] Basic MATLAB 3D graphics are working.\n");
catch graphicsError
    fprintf("\n[ERROR] Graphics test failed:\n");
    fprintf("%s\n", graphicsError.message);
end