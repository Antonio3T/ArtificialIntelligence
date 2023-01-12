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

% Random Coordenates

x = (x_max - x_min)*rand + x_min;
y = (y_max - y_min)*rand + y_min;

hold on
plot(x, y, 'r*')

% Initialize Values and Variables

maxiterations = 1000;

temperature = 90;

increment = 10; % iterations per temperature value, second "while"

alpha = 0.94; % lowering temperature factor

old_ftxy = 0;
new_ftxy = 0;

% Internal and External Cycles

externalcycle = 0;
internalcycle = 0;

%

external_temperature = zeros(maxiterations, 1);

external_probability = zeros(increment ,1);

% ftxy(x+1) - ftxy(x)

internal_probability = zeros(increment*maxiterations, 1);
difference = zeros(increment*maxiterations, 1);

% Function Value by Iterations

ftxy_by_iterations = zeros(increment*maxiterations, 1);

% First x and y

ftxy_by_iterations(1) = ftxy(x, y);

% Temperature Initialization

external_temperature(1) = temperature;

%

best_x = x;
best_y = y;

%

k = 1; % Iterations Count

while externalcycle < maxiterations

    internalcycle = 1;

    while(internalcycle <= increment)
        new_x = (max_sum - min_sum)*rand + min_sum + x;
        new_y = (max_sum - min_sum)*rand + min_sum + y;
        
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
        
        old_ftxy = ftxy(x, y);
        new_ftxy =  ftxy(new_x, new_y);

        % Check Best for Every Iteration

        if(ftxy(best_x, best_y) < new_ftxy)
            best_x = new_x;
            best_y = new_y;
        end

        difference(k) = new_ftxy - old_ftxy;

        internal_probability(k) = ProbabilityFunction(difference(k), temperature);

        %

        ftxy_by_iterations(k) = new_ftxy;

        if difference(k) > 0
            x = new_x;
            y = new_y;
        end

        if rand() < internal_probability(k)
            x = new_x;
            y = new_y;
        end

        internalcycle = internalcycle + 1; % Internal Cycle

        plot(x, y, 'b.')

        k = k + 1;
    end

    %

    temperature = temperature*alpha;

    externalcycle = externalcycle + 1;

    external_temperature(externalcycle + 1) = temperature;
end

% Graphs

%

figure
plot(internal_probability, 'b')
title('Probability Per Iteration')
xlabel('Iterations')
ylabel('Probability')
%

figure
stairs(external_temperature, 'r') % plot(external_temperature, 'r')
title('Temperature Per Iterations')
xlabel('Iterations')
ylabel('Temperature')

%

fprintf('x -> %f\n', best_x)
fprintf('y -> %f\n', best_y)
