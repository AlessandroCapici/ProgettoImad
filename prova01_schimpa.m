% Ho fatto un primo modellino un po' a caso usando le serie di Fourier, e
% in particolare con delle sinusioidi a periodicità annuale e delle
% sinusoidi a periodicità settimanale. 

clear
close all
%% Caricamento dati
load('caricoDEday.mat')
dati = table2array(caricoDEday);

%% Variabili utili
dayOfYear = dati(:,1);
dayOfWeek = dati(:,2);
carico = dati(:,3);
x_vec = (1:length(carico))';
carico_n = normalize(carico);
n_dati = length(carico);

%% Identificazione del modello
%Per identificare il modello uso solo una parte dei dati (non so perchè se uso più dati thetaLS mi esce NaN)
inizio_dati=100;
dati_usati=300;

Phi = [ones(dati_usati+1,1) ...x_vec(inizio_dati:dati_usati+inizio_dati)...
    cos(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi/365) sin(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi/365)...
    ...cos(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi*2/365) sin(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi*2/365)...
    cos(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi/7) sin(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi/7)...
    cos(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi*2/7) sin(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi*2/7)...
    cos(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi*3/7) sin(x_vec(inizio_dati:dati_usati+inizio_dati)*2*pi*3/7)];

[thetaLS,var_theta,SSR] = stimaLS(carico_n(inizio_dati:dati_usati+inizio_dati),Phi);
disp(thetaLS)

%% Plot di modello e dati
Phi1 = [ones(n_dati,1) ...x_vec 
    cos(x_vec*2*pi/365) sin(x_vec*2*pi/365)...
    ...cos(x_vec*2*pi*2/365) sin(x_vec*2*pi*2/365)...
    cos(x_vec*2*pi/7) sin(x_vec*2*pi/7)...
    cos(x_vec*2*pi*2/7) sin(x_vec*2*pi*2/7)...
    cos(x_vec*2*pi*3/7) sin(x_vec*2*pi*3/7)];

figure(1)
plot(x_vec,carico_n,'o-')
grid on
hold on
plot(x_vec,Phi1*thetaLS)

legend('dati', 'stima')
