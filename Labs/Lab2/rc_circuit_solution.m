% simple first-order ODE: an RC network with switch closing to DC input 
% at t=0
clear
close all

R=1;
C=.1;
a = -1/(R*C);
vin=1;

h=.01;
t=0:h:1;
N= length(t);

% explicit solution of the ODE
vexp = vin*(1-exp(a*t));

% approximated: difference equation
vapp = zeros(N,1)
for k=2:N
    vapp(k) = (1+a*h)*vapp(k-1) - a*h*vin
end


plot(t,vexp,'b',t,vapp,'r')
grid on
title('First Order ODE Approximation: RC Circuit')
xlabel('time (s)');
ylabel('Vcap (volts)');
legend('Analytical Solution', 'Numerical Approximation')