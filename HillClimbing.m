% Function Definition

a = 3;
b = 10;

% f1xy = @(x, y)	a.*(1-x.^2).*exp(-x.^2 - (1 + y).^2);
% f2xy = @(x, y)	-b.*(x./5 - x.^3 - x.^5).*exp(-x.^2 - y.^2);
% f3xy = @(x, y)	(-1/3)*exp(-(x + 1).^2 - y.^2);

% ftxy = f1xy(x, y) + f2xy(x, y) + f3xy(x, y);

% xy_max = [3 3];
% xy_min = [-3 -3];

%

ftxy = @(x, y)	a.*(1-x.^2).*exp(-x.^2 - (1 + y).^2) -b.*(x./5 - x.^3 - x.^5).*exp(-x.^2 - y.^2) + (-1/3)*exp(-(x + 1).^2 - y.^2);

% Function Limits

x = linspace(-3, 3, 100);
y = linspace(-3, 3, 100);

% Rectangular Grid (Cartesian Coordinate System)

[X, Y] = meshgrid(x, y);

ftXY = ftxy(X, Y);

contour(X, Y, ftXY, 20)

%

x_min = -3;
x_max = 3;
y_min = -3;
y_max = 3;

% Increment Limits

min_sum = -0.03;
max_sum = 0.03;

% History of Coordenates

maxiterations = 1000;

x_coordenates = zeros(maxiterations, 1);
y_coordenates = zeros(maxiterations, 1);

% Random Coordenates

x = (x_max - x_min)*rand + x_min;
y = (y_max - y_min)*rand + y_min;

hold on
plot(x, y, 'r*')

% Initial Values and Variables

x_coordenates(1) = x;
y_coordenates(1) = y;

txy(1) = ftxy(x, y);

best_x = x;
best_y = y;

%

for k = 2:maxiterations
    new_x = (max_sum - min_sum) * rand + min_sum + x;
    new_y = (max_sum - min_sum) * rand + min_sum + y;

    % Check Limits

    if new_x > x_max
        new_x = x_max;
    end
    if new_y > y_max
        new_y = y_max;
    end
    if new_x < x_min
        new_x = x_min;
    end
    if new_y < y_min
        new_y = y_min;
    end

    % Does The Change Give a Better Solution?

    if ftxy(new_x, new_y) > ftxy(x, y)
        x = new_x;
        y = new_y;

        plot(x, y, 'b.')
    end

    % Check Best for Every Iteration

    if ftxy(best_x, best_y) < ftxy(new_x, new_y)
        best_x = new_x;
        best_y = new_y;
    end

    x_coordenates(k) = x;
    y_coordenates(k) = y;

    txy(k) = ftxy(x_coordenates(k), y_coordenates(k));
end

% Graphics and Representations

figure

title('x and y by Iteration')

plot(x_coordenates, 'b')

hold on

plot(y_coordenates, 'g')

hold off

xlabel('Iterations');
ylabel('x - Blue, y - Green');

%

figure

plot(txy, 'r')
title('')
xlabel('Number of Iterations')
ylabel('ftxy(x, y)')

%

fprintf('x -> %f\n', best_x)
fprintf('y -> %f\n', best_y)
