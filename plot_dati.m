clear
close all

load('caricoDEday.mat')
dati = table2array(caricoDEday);

figure(1)
plot(dati(:,3),'o-')
grid on

% Preriodicit� annuale, preriodicit� settimanale e trend in salita
