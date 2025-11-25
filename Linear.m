clc
clear
close all
%% Plant Configuration
Do1 = 6e-3;                     % m
Do2 = 3e-3;                     % m
D1 = 4.5e-2;                    % m
D2 = 4.5e-2;                    % m
Cd1=0.8;                        % unitless
Cd2=0.8;                        % unitless

Kpump = 0.0000035;                   % L/s/V              

% Calculation of orifice areas
Ao1 = (pi/4)*(Do1)^2;           % m^2
Ao2 = (pi/4)*(Do2)^2;           % m^2
A1 = (pi/4)*(D1)^2;             % m^2
A2 = (pi/4)*(D2)^2;             % m^2

%% Operating point

h20=0.1;                        % m
h10=h20*Ao2*Cd2/(Ao1*Cd1);      % Calculate h10 from h20.

%% Controller

g=9.81;

%% Systems

Gpump = zpk([],[],Kpump);                                       % Pump

Gh1 = zpk([],-Ao1*Cd1*sqrt(2*g)/(A1*2*sqrt(h10)),1/A1)         % Tank 1 h1/qi

Gqo1 = zpk([],[],Ao1*Cd1*sqrt(2*g)/(2*sqrt(h10)))              % Tank 1 qo1/h1

Gh2 = zpk([],-Ao2*Cd2*sqrt(2*g)/(A2*2*sqrt(h20)),1/A2)         % Tank 2 h2/qo1

Gpd = tf(1, [1, 0.3648]);           % Cascade controller

%% Simulation
Gpump*Gh1*Gqo1*Gh2
Tunc = feedback(Gpump*Gh1*Gqo1*Gh2,1);      % Uncompensated negative unity feedback

Dunc = feedback(Gh2,Gpump*Gh1*Gqo1);        % Uncompensated disturbance response

T = feedback(Gpd*Gpump*Gh1*Gqo1*Gh2,1);    % Negative unity feedback

D = feedback(Gh2,Gpd*Gpump*Gh1*Gqo1);      % Disturbance response

%% Responses
% Poles/zeros + rlocus
figure
pzplot(Gpump*Gh1*Gqo1*Gh2)
hold on
print("Pole_Zero.png", "-dpng")
%pzplot(Gpd)
%legend({'Uncompensated','PID'})
title('Open Loop Pole Zero Plot')

figure;
rlocusplot(Gpump*Gh1*Gqo1*Gh2);
title('Uncompensated Root Locus');
print("Root_Locus.png", "-dpng")

figure;
rlocusplot(Gpd*Gpump*Gh1*Gqo1*Gh2);
title('Compensated Root Locus');
print("Comp_Root_Locus.png", "-dpng")

figure;
pzplot(T);
title('Compensated Closed Loop Poles/Zeros');
print("Compenstated_CL_PZ.png", "-dpng")

% Time responses
% Open Loop
figure;
step(Tunc,RespConfig('Amplitude',10e-2,'Bias',0))
title('Input Response')
print("Step.png", "-dpng")

figure;
step(Dunc,RespConfig('Amplitude',10e-2,'Bias',0))
title('Disturbance Response')

% Closed loop
figure
subplot(1,2,1)
step(T,RespConfig('Amplitude',0.01,'Bias',0))
title('Input Response')

subplot(1,2,2)
step(D,RespConfig('Amplitude',-0.00001,'Bias',0))
title('Disturbance Response')

% Nyquist
figure
subplot(1,2,1)
nyquist(Gpump*Gh1*Gqo1*Gh2)
title('Uncompensated')

subplot(1,2,2)
nyquist(Gpd*Gpump*Gh1*Gqo1*Gh2)
title('Compensated')

% Frequency response
figure
subplot(1,2,1)
np1 = nyquistplot(Gpump*Gh1*Gqo1*Gh2);
np1.ShowNegativeFrequencies = "off";
title('Uncompensated')

subplot(1,2,2)
np2 = nyquistplot(Gpd*Gpump*Gh1*Gqo1*Gh2);
np2.ShowNegativeFrequencies = "off";
title('Compensated')
