clc
clear
close all

data = load("Noise.mat");

noise_data = data.simOut_20251008_100044;

time = noise_data.tout;
h1 = noise_data.measurements.Tank_1_Level__m_.Data;
h2 = noise_data.measurements.Tank_2_Level__m_.Data;
step = noise_data.ref_signal.Data;

headers = {'time', 'h1', 'h2', 'step'};
csv = [time'; h1'; h2'; step']';
T = array2table(csv);
csvwrite('Noise.csv', csv)

hold on;
plot(time, h1)
plot(time, h2)
plot(time, step)

step_time = time(2) - time(1);
fs = 1/step_time;
% op 1 = 50->100
t1 = 50;
t2 = 100;
op1_time = time((t1/step_time + 1):(t2/step_time + 1));
op1_h1 = h1((t1/step_time + 1):(t2/step_time + 1));
op1_h2 = h2((t1/step_time + 1):(t2/step_time + 1));

std_op1_h1 = std(op1_h1);
std_op1_h2 = std(op1_h2)

% op 2 = 150->200
t1 = 150;
t2 = 200;
op2_time = time((t1/step_time + 1):(t2/step_time + 1));
op2_h1 = h1((t1/step_time + 1):(t2/step_time + 1));
op2_h2 = h2((t1/step_time + 1):(t2/step_time + 1));

std_op2_h1 = std(op2_h1);
std_op2_h2 = std(op2_h2)

% op 3 = 250->320
t1 = 250;
t2 = 320;
op3_time = time((t1/step_time + 1):(t2/step_time + 1));
op3_h1 = h1((t1/step_time + 1):(t2/step_time + 1));
op3_h2 = h2((t1/step_time + 1):(t2/step_time + 1))

std_op3_h1 = std(op3_h1)
std_op3_h2 = std(op3_h2)

sprintf("At h_2 = 10cm the std is %.2f", std_op1_h2)
sprintf("At h_2 = 15cm the std is %.2f", std_op2_h2)
sprintf("At h_2 = 25cm the std is %.2f", std_op3_h2)

x_points = [0.1, 0.15, 0.25];
y_points = [std_op1_h2, std_op2_h2, std_op3_h2];

% Create a new figure
figure;

% Loop through each segment
for i = 1:length(x_points)-1
    % Define segment points
    x_segment = x_points(i:i+1);
    y_segment = y_points(i:i+1);
    
    % Plot the segment
    plot(x_segment, y_segment, '-o', 'MarkerFaceColor', 'r');
    hold on;  % Retain the plot for the next segment
end

% Additional formatting
xlabel('X-axis');
ylabel('Y-axis');
title('Piecewise Linear Segments');
grid on;
legend('Line Segments');


% Number of segments
num_segments = length(x_points) - 1;

% Initialize arrays for slopes and intercepts
slopes = zeros(1, num_segments);
intercepts = zeros(1, num_segments);
equations = cell(1, num_segments);  % Cell array to hold equations

% Calculate slopes and intercepts, and create equations
for i = 1:num_segments
    slopes(i) = (y_points(i+1) - y_points(i)) / (x_points(i+1) - x_points(i));
    intercepts(i) = y_points(i) - slopes(i) * x_points(i);
    
    % Create the equation for each segment
    sprintf('y = %.2fx + %.2f, for %g <= x < %g', slopes(i), intercepts(i), x_points(i), x_points(i+1))
end
