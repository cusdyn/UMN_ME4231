% RC circuit with switch close to AV voltage at t=0
% 'unity' model: 1's for our parameters to observe phenomena
clear
close all
fignum=1;

R=1;
C=1;

a = -1/(R*C);

% get Matlab's magnitude a pahse as a function of frequency
num = -a;
den = [1 -a];
[MAG,PH,W] = bode(num,den);


figure(fignum)
fignum = fignum + 1;
subplot(4,1,1)
title('Stepping our RC filter reponse across Malab Bode plot')
pltMag = plot(W,MAG,'r',W(1),MAG(1),'bo');
xlabel('frequency (rad/sec)')
ylabel('gain (fraction)');
subplot(4,1,2)
pltPhase = plot(W,PH,'r',W(1),PH(1),'bo');
xlabel('frequency (rad/sec)')
ylabel('relative phase (deg)');
subplot(4,1,3)
pltLogMag = semilogx(W,20*log(MAG),'r',W(1),20*log(MAG(1)),'bo');
xlabel('frequency (rad/sec)')
ylabel('gain (dB)');
subplot(4,1,4)
pltLogPhase = semilogx(W,PH,'r',W(1),PH(1),'bo');
xlabel('frequency (rad/sec)')
ylabel('relative phase (deg)');

set(gcf,'position',[0,0,600,900]);


figure(fignum)
fignum = fignum + 1;
pltTimeResponse = plot(0,0,'b',0,0,'r');
ax = gca;

grid on
title('First Order ODE Approximation: RC Circuit')
xlabel('time (s)');
ylabel('Vcap (volts)');


for k=1:length(W),
    w = W(k);
    h=.001;

    t=0:h:20/w;
    N= length(t);

    vin = 1/a*cos(w*t);
    M = -a/(w^2 + a^2);
    N = w/(w^2 + a^2);
    % the brute-force "recatngular" solution
    v = -M*(cos(w*t)-exp(a*t)) + N*sin(w*t);
    set(pltTimeResponse(1),'XData',t,'YData',vin);
    set(pltTimeResponse(2),'XData',t,'YData',v);
    ax.XLim = [0 40/(pi*w)];
    %set(pltTimeResponse,'xlim',[0 1/(pi*w)]);
    % Gain and phase from the polar form
    R = sqrt(M^2 + N^2);
    P = -atan(N/M)*180/pi;
    set(pltMag(2),'XData',w,'YData',R);
    set(pltPhase(2),'XData',w,'YData',P);
    set(pltLogMag(2),'XData',w,'YData',20*log(R));
    set(pltLogPhase(2),'XData',w,'YData',P);
    
    pause(0.5);
end

