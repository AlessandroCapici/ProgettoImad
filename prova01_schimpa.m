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
thetaLS=Phi\carico;
% [thetaLS,var_theta,SSR] = stimaLS(carico_n,Phi);
% disp(thetaLS)

%% Plot di modello e dati

figure(1)
plot(dati(:,4),carico,'o-')
grid on
hold on
plot(dati(:,4),Phi*thetaLS)

legend('dati', 'stima')

%% Stessa stima ma scritta leggermente diversa (e piu' giusta)

Phi2 = [ones(728,1) dati(1:end,4)...
    cos(dati(1:end,1)*2*pi/365) sin(dati(1:end,1)*2*pi/365)...
    cos(dati(1:end,2)*2*pi/7) sin(dati(1:end,2)*2*pi/7)...
    cos(dati(1:end,2)*2*pi*2/7) sin(dati(1:end,2)*2*pi*2/7)...
    cos(dati(1:end,2)*2*pi*3/7) sin(dati(1:end,2)*2*pi*3/7)];
thetaLS2=Phi2\carico;

figure(2)
plot(dati(:,4),carico,'o-')
grid on
hold on
plot(dati(:,4),Phi2*thetaLS2)

legend('dati', 'stima')

%% Se usassi un solo anno per identificare il modello
Phi3 = [ones(364,1) dati(365:end,4)...
    cos(dati(365:end,1)*2*pi/365) sin(dati(365:end,1)*2*pi/365)...
    cos(dati(365:end,2)*2*pi/7) sin(dati(365:end,2)*2*pi/7)...
    cos(dati(365:end,2)*2*pi*2/7) sin(dati(365:end,2)*2*pi*2/7)...
    cos(dati(365:end,2)*2*pi*3/7) sin(dati(365:end,2)*2*pi*3/7)];
thetaLS3=Phi3\carico(365:end);


figure(3)
plot(dati(:,4),carico,'o-')
grid on
hold on
plot(dati(:,4),Phi2*thetaLS3)

legend('dati', 'stima')

% Questo fa schifo, perchè non ha dentro il trend di salita

%%
Phi4 = [ones(728,1) dati(:,4)];
thetaLS4=Phi4\(dati(:,3));

trend = Phi4*thetaLS4;

figure(4)
plot(dati(:,4),carico,'o-')
grid on
hold on
plot(dati(:,4),Phi4*thetaLS4)

legend('dati', 'stima')


%% Dati senza trend
figure(5)
plot(dati(:,4), dati(:,3)-trend,'o-')
grid on
