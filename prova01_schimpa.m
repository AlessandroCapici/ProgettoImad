% Ho fatto un primo modellino un po' a caso usando le serie di Fourier, e
% in particolare con delle sinusioidi a periodicità annuale e delle
% sinusoidi a periodicità settimanale. 

clear
close all
%% Caricamento dati
load('caricoDEday.mat')
dati = table2array(caricoDEday);

x_vec = (1:size(dati,1))';
dati =  [dati x_vec];
%% Eliminazione dei NaN
emptyRows=[];
for i=dati(:,4)'
    if isnan(dati(i,3))
        emptyRows=[emptyRows i];
    end
end

emptyRows=flip(emptyRows);  % Rimuovo i NaN a partire dalla fine se no mi scalano gli indici e rimuovo righe non NaN
for i=emptyRows
    disp(i)
    dati(i,:)=[]; 
end
%% Variabili utili
dayOfYear = dati(:,1);
dayOfWeek = dati(:,2);
carico = dati(:,3);
carico_n = normalize(carico);
n_dati = length(carico);

%% Identificazione del modello
%Per identificare il modello uso solo una parte dei dati (non so perchè se uso più dati thetaLS mi esce NaN)

Phi = [ones(728,1) dati(1:end,4)...
    cos(dati(1:end,4)*2*pi/365) sin(dati(1:end,4)*2*pi/365)...
    cos(dati(1:end,4)*2*pi/7) sin(dati(1:end,4)*2*pi/7)...
    cos(dati(1:end,4)*2*pi*2/7) sin(dati(1:end,4)*2*pi*2/7)...
    cos(dati(1:end,4)*2*pi*3/7) sin(dati(1:end,4)*2*pi*3/7)];
thetaLS=Phi\carico
% [thetaLS,var_theta,SSR] = stimaLS(carico_n,Phi);
% disp(thetaLS)

%% Plot di modello e dati
Phi1 = [ones(size(dati,1),1) dati(:,4)...
    cos(dati(:,4)*2*pi/365) sin(dati(:,4)*2*pi/365)...
    ...cos(x_vec*2*pi*2/365) sin(x_vec*2*pi*2/365)...
    cos(dati(:,4)*2*pi/7) sin(dati(:,4)*2*pi/7)...
    cos(dati(:,4)*2*pi*2/7) sin(dati(:,4)*2*pi*2/7)...
    cos(dati(:,4)*2*pi*3/7) sin(dati(:,4)*2*pi*3/7)];

figure(1)
plot(dati(:,4),carico,'o-')
grid on
hold on
plot(dati(:,4),Phi1*thetaLS)

legend('dati', 'stima')
