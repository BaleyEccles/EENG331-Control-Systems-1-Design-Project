%% Plant Configuration

Do1 = 6e-3;                     % m
Do2 = 3e-3;                     % m
D1 = 4.5e-2;                    % m
D2 = 4.5e-2;                    % m
Cd1=0.8;                        % unitless
Cd2=0.8;                        % unitless

Kpump = 2e-5;                   % L/s/V              

% Calculation of orifice areas
Ao1 = (pi/4)*(Do1)^2;           % m^2
Ao2 = (pi/4)*(Do2)^2;           % m^2
A1 = (pi/4)*(D1)^2;             % m^2
A2 = (pi/4)*(D2)^2;             % m^2

%% Operating point

h20=0.1;                        % m
h10=h20*Ao2*Cd2/(Ao1*Cd1);      % Calculate h10 from h20.

%% Controller

% note these are just placeholder values
Kp=100;                         % V/m
Ki=1;                           % V/ms
Kd=100;                         % Vs/m
Tf=100;                         % s

g=9.81;

%% Systems

Gpump = zpk([],[],Kpump);                                       % Pump

Gh1 = zpk([],-Ao1*Cd1*sqrt(2*g)/(A1*2*sqrt(h10)),1/A1);         % Tank 1 h1/qi

Gqo1 = zpk([],[],Ao1*Cd1*sqrt(2*g)/(2*sqrt(h10)));              % Tank 1 qo1/h1

Gh2 = zpk([],-Ao2*Cd2*sqrt(2*g)/(A2*2*sqrt(h20)),1/A2);         % Tank 2 h2/qo1

Gpid = tf([(Kd+Kp*Tf), (Kp + Ki*Tf), Ki],[Tf, 1, 0]);           % Cascade controller

%% Simulation

Tunc = feedback(Gpump*Gh1*Gqo1*Gh2,1);      % Uncompensated negative unity feedback

Dunc = feedback(Gh2,Gpump*Gh1*Gqo1);        % Uncompensated disturbance response

T = feedback(Gpid*Gpump*Gh1*Gqo1*Gh2,1);    % Negative unity feedback

D = feedback(Gh2,Gpid*Gpump*Gh1*Gqo1);      % Disturbance response

%% Responses
% Poles/zeros + rlocus
figure
subplot(1,3,1)
pzplot(Gpump*Gh1*Gqo1*Gh2)
hold on
pzplot(Gpid)
legend({'Uncompensated','PID'})
title('Open Loop Pole Zero Plot')

subplot(1,3,2)
rlocusplot(Gpid*Gpump*Gh1*Gqo1*Gh2);
title('Compensated Root Locus');

subplot(1,3,3)
pzplot(T);
title('Compensated Closed Loop Poles/Zeros');

% Time responses
% Open Loop
figure
subplot(1,2,1)
step(Tunc,RespConfig('Amplitude',0.01,'Bias',0))
title('Input Response')

subplot(1,2,2)
step(Dunc,RespConfig('Amplitude',-0.00001,'Bias',0))
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
nyquist(Gpid*Gpump*Gh1*Gqo1*Gh2)
title('Compensated')

% Frequency response
figure
subplot(1,2,1)
np1 = nyquistplot(Gpump*Gh1*Gqo1*Gh2);
np1.ShowNegativeFrequencies = "off";
title('Uncompensated')

subplot(1,2,2)
np2 = nyquistplot(Gpid*Gpump*Gh1*Gqo1*Gh2);
np2.ShowNegativeFrequencies = "off";
title('Compensated')
