% plot results of Lab2 RC circuit C codea
clear
close all

d = table2array(readtable('..\x64\Debug\RCout.txt'),'NumHeaderLines',3);
R = d(1,2)
C = d(2,2)
plot(d(4:length(d),1),d(4:length(d),2),'o')
title(sprintf('RC network output from C program.\nR=%0.0f ohms\nC=%f farads',R,C));
xlabel('time (s)')
ylabel('Vcap (volts)')
