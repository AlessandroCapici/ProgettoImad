% In questo script abbiamo fatto varie prove per stimare l'andamento del
% modello, escludendo le vacanze di Natale per le quali abbiamo deciso di
% fare un modello a parte.

clear
close all
clc

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

% Stimo i dati mancanti
for i = emptyRows
    dati(i,3)= (dati(i-7,3)+dati(i+7,3))/2;
end

%% De-trendizzazione e normalizzazione
% Ad ogni anno sottraiamo la media annuale calcolata su quell'anno

mean_year1 = mean(dati(1:365,3));
mean_year2 = mean(dati(366:end,3));

vec=[mean_year1*ones(365,1); mean_year2*ones(365,1)];

dati(:,3) = dati(:,3)-vec;

sd = std(dati(:,3));
dati(:,3)=(1/sd)*dati(:,3);

%% Pulizia vacanze natalizie

rowsToDelete = [];
for i=dati(:,4)'
   if dati(i,1)<7 | dati(i,1)>356
       rowsToDelete = [rowsToDelete i];
   end
end

rowsToDelete = flip(rowsToDelete);

for j = rowsToDelete
    dati(j,:)=[];
end

%% Plot dati
figure(1)
plot(dati(:,4), dati(:,3),'o-')
grid on
title('Dati senza vacanze di Natale')

%% Prova dei modelli
% Abbiamo provato a stimare modelli con le serie di Fourier, e abbiamo
% usato sia la cross-validazione sia i criteri oggettivi per scegliere la
% complessità del modello. L'uso delle serie di Fourier ci ha soddisfatto
% per quanto riguarda l'andamento settimanale, mentre per l'andamento
% annuale non siamo riusciti a ottenere andamenti che seguissero bene i
% dati

% i=1;
% f=350;
% 
% Phi = [cos(2*pi*dati(i:f,1)/365) sin(2*pi*dati(i:f,1)/365)...
%     cos(2*pi*dati(i:f,1)*2/365) sin(2*pi*dati(i:f,1)*2/365)...
%     cos(2*pi*dati(i:f,1)*3/365) sin(2*pi*dati(i:f,1)*3/365)...
%     cos(2*pi*dati(i:f,1)*4/365) sin(2*pi*dati(i:f,1)*4/365)...
%     cos(2*pi*dati(i:f,2)/7) sin(2*pi*dati(i:f,2)/7)...
%     cos(2*pi*dati(i:f,2)*2/7) sin(2*pi*dati(i:f,2)*2/7)...
%     cos(2*pi*dati(i:f,2)*3/7) sin(2*pi*dati(i:f,2)*3/7)];
% 
% [N,q]=size(Phi);
% [thetaLS,var_theta,SSR] = stimaLS(dati(i:f,3),Phi);
% 
% [fpe,aic,mdl] = test(N,q,SSR);
% 
% Phi_tutto = [cos(2*pi*dati(:,1)/365) sin(2*pi*dati(:,1)/365)...
%     cos(2*pi*dati(:,1)*2/365) sin(2*pi*dati(:,1)*2/365)...
%     cos(2*pi*dati(:,1)*3/365) sin(2*pi*dati(:,1)*3/365)...
%     ...cos(2*pi*dati(:,1)*4/365) sin(2*pi*dati(:,1)*4/365)...
%     cos(2*pi*dati(:,2)/7) sin(2*pi*dati(:,2)/7)...
%     cos(2*pi*dati(:,2)*2/7) sin(2*pi*dati(:,2)*2/7)...
%     cos(2*pi*dati(:,2)*3/7) sin(2*pi*dati(:,2)*3/7)];
% stima = Phi_tutto*thetaLS;
% 
% Phi_val = [cos(2*pi*dati(f+1:end,1)/365) sin(2*pi*dati(f+1:end,1)/365)...
%     cos(2*pi*dati(f+1:end,1)*2/365) sin(2*pi*dati(f+1:end,1)*2/365)...
%     cos(2*pi*dati(f+1:end,1)*3/365) sin(2*pi*dati(f+1:end,1)*3/365)...
%     ...cos(2*pi*dati(f+1:end,1)*4/365) sin(2*pi*dati(f+1:end,1)*4/365)...
%     cos(2*pi*dati(f+1:end,2)/7) sin(2*pi*dati(f+1:end,2)/7)...
%     cos(2*pi*dati(f+1:end,2)*2/7) sin(2*pi*dati(f+1:end,2)*2/7)...
%     cos(2*pi*dati(f+1:end,2)*3/7) sin(2*pi*dati(f+1:end,2)*3/7)];
% stima_val = Phi_val*thetaLS;
% errore = stima_val - dati(f+1:end,3);
% SSRv = errore'*errore;
% 
% figure(2)
% plot(dati(:,4), dati(:,3),'o-')
% grid on
% hold on
% plot(dati(:,4),stima)

% save ./salvataggi/prova7.mat fpe aic mdl SSRv q 

%% Stima del modello settimanale
% Stimiamo solo l'andamento settimanale usando le serie di Fourier, e poi
% lo sottraiamo ai dati. Useremo i dati ripuliti dall'andamento settimanale
% per ottenrere l'andamento annuale.

Phi_tutto = [cos(2*pi*dati(:,2)/7) sin(2*pi*dati(:,2)/7)...
    cos(2*pi*dati(:,2)*2/7) sin(2*pi*dati(:,2)*2/7)...
    cos(2*pi*dati(:,2)*3/7) sin(2*pi*dati(:,2)*3/7)];
[N,q]=size(Phi_tutto);
[thetaLS,var_theta,SSR] = stimaLS(dati(:,3),Phi_tutto);
stima = Phi_tutto*thetaLS;

figure(2)
plot(dati(:,4), dati(:,3),'o-')
grid on
hold on
plot(dati(:,4),stima)

%save ./salvataggi/prova_poli4.mat fpe aic mdl SSRv q 

dati_new = dati;
dati_new(:,3) = dati_new(:,3)-stima;

figure(3)
plot(dati_new(:,4), dati_new(:,3))

%% Stima dell'andamento annuale usando i dat a cui e' stato tolto l'andamento settimanale

i=1;
f=700;

% Abbiamo usato la funzione stepwise di matlab per avere un'idea della
% complessità del modello da usare, ma poi abbiamo fatto delle prove a mano
% per fare la scelta definitva
mdl1 = stepwiselm(dati_new(i:f,1),dati_new(i:f,3),'poly5','Criterion','aic');
figure(4)
plot(mdl1) %funzione trovata '1 + x1 + x1^2 + x1^3 + x1^4'


% In realtà la stima viene fatta su entrambi gli anni ora
Phi_anno1 = [ones(f,1) dati_new(i:f,1) dati_new(i:f,1).^2 dati_new(i:f,1).^3]; %primo anno
[N,q]=size(Phi_anno1);
[thetaLS,var_theta,SSR] = stimaLS(dati(i:f,3),Phi_anno1);
stimaanno1 = Phi_anno1*thetaLS;
[fpe,aic,mdl] = test(N,q,SSR);
% Il terzo grado è la nostra scelta definitiva


stimatot=stimaanno1;
figure(4)
plot(dati_new(:,4), dati_new(:,3),'o-')
grid on
hold on
plot(dati_new(:,4),stimatot)

supermegastima=stima+stimatot;
figure(5)
plot(dati(:,4), dati(:,3),'o-')
grid on
hold on
plot(dati(:,4),supermegastima)

