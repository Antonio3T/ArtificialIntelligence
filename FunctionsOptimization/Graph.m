% Function Definition

a = 3;
b = 10;

% f1xy = @(x, y)	a.*(1-x.^2).*exp(-x.^2 - (1 + y).^2);
% f2xy = @(x, y)	-b.*(x./5 - x.^3 - x.^5).*exp(-x.^2 - y.^2);
% f3xy = @(x, y)	(-1/3)*exp(-(x + 1).^2 - y.^2);

% ftxy = f1xy(x, y) + f2xy(x, y) + f3xy(x, y);

% xy_max = [3 3];
% xy_min = [-3 -3];

% Definition and Limits

ftxy = @(x, y)	a.*(1-x.^2).*exp(-x.^2 - (1 + y).^2) -b.*(x./5 - x.^3 - x.^5).*exp(-x.^2 - y.^2) + (-1/3)*exp(-(x + 1).^2 - y.^2);

x = linspace(-3, 3, 100);
y = linspace(-3, 3, 100);

% Rectangular Grid

[X, Y] = meshgrid(x, y);

ftXY = ftxy(X, Y);

contour(X, Y, ftXY, 20)

% Random Coordenates

rx = (rand - 0.5)*2*3;
ry = (rand - 0.5)*2*3;

% Graph

hold on
plot(rx, ry, 'ro')

hold off
