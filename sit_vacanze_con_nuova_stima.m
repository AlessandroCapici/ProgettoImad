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

dati_con_0=dati;

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

%% parte nuova
%% rendo supermegastima compatibile con "mio" codice.

vacanze=zeros(365,1);
%                   1/01  6/01, 24/02, 10/03, 13/03, 1/05, 10/05, 21/05, 30/05, 11/06, 15/08, 19/09, 3/10, 31/10, 18/11, 25/12
giorni_vacanze = [   1,   6,    55,  130,   141,    151,  162,   227,   262,  304,  322,   359];
%rimosso quelli che facevano casini sono 100 103 114 121 276 <- in partic.
vacanze (giorni_vacanze) = 1;


Y_hat=zeros(730,1);
Y_hat(7:356)=supermegastima(1:350);
Y_hat(372:721)= supermegastima(351:end);

dati=dati_con_0;

for j = rowsToDelete
    dati(j,3)=0;
end


figure(6)
plot(dati(:,3))
hold on
plot(Y_hat,  "LineWidth", 2)
grid on
legend('Dati','stima')
title('dati normalizzati e modello iniziale')

errore = Y_hat-dati(:,3);
%devo limitare range di errore tra 14 e 356
rowsToDelete=zeros(730,1)+1; %vettore di 1
for i=dati(:,4)'
   if dati(i,1)<7 || dati(i,1)>356
       rowsToDelete(i)=0; %imposto righe da eliminare in posizione i a 0
   end
end
errore=rowsToDelete.*errore;

figure(7)
plot(dati(:,4),errore)
grid on
title('dati - modello in range [14:356]');

A=1;
B=ones(1,7)/7;
errore_mm=filter(B,A,errore);
%per tenere conto di picchi in prossimità a giorni di vacanza:
errore_mm_somma=[errore_mm(1:365)+errore_mm(366:end)];
%per girare l'errore dato che ora sono invertiti
errore_mm_somma = -errore_mm_somma;
figure(8);
plot (errore_mm_somma)
title("mm finestra di 7 giorni su errori sommati tra due anni");
%per pulire dati sostituisco con 0 elementi che meno si allontanano.
errore_mm_somma_pulito = zeros(365,1);


for i = 1:365
    if (abs(errore_mm_somma(i)) < 0.1)
        errore_mm_somma_pulito(i)=0;
        continue;
    end
    if(errore_mm_somma(i) < -0.1)
        errore_mm_somma_pulito(i)=1;
    end
end

errore_con_medie=zeros(365,1);

inizio=0;
fine=0;
per_fare_una_media=[];
for i = 1:365
    if(errore_mm_somma_pulito(i)~=0)
        if(inizio==0)
            inizio=i;
        end;
        per_fare_una_media=[per_fare_una_media errore_mm_somma(i)];
    end
    if(errore_mm_somma_pulito(i)==0 && ~isempty(per_fare_una_media))
        fine=i;
        errore_con_medie(inizio:fine)=mean(per_fare_una_media);
        per_fare_una_media=[];
        inizio=0;
    end
end


vacanze_effettive=zeros(365,1);
for i = 1:365
    if (vacanze(i)~=0)
        if(abs(errore_mm_somma_pulito(i))==vacanze(i))
            vacanze_effettive(i)=0.5;
        end
    end
end

%devo ora applicare per_fare_una_media solo dove vacanze_effettive !=0
inizio=0;
flag = false;
per_fare_una_media_appiattito=errore_con_medie;
for i = 1: length(per_fare_una_media_appiattito)
    if inizio==0 && errore_con_medie(i)<0
        inizio=i;
    end
    if inizio ~= 0 && vacanze_effettive(i)~=0
        flag=true;
    end
    if inizio ~= 0 && errore_con_medie(i) ==0 && flag == false
        per_fare_una_media_appiattito(inizio:i)=0;
        inizio = 0;
        flag = false;
    end
    if inizio~= 0 && errore_con_medie(i) ==0 && flag == true
        inizio=0;
        flag=false;
    end
end

figure(9)
plot(errore_con_medie, "blue")
hold on
plot(per_fare_una_media_appiattito, "green", "LineWidth", 2);
hold on
plot(vacanze_effettive)
title("errore medio solo in prossimità di vacanze effettive");


errore_con_medie=per_fare_una_media_appiattito;






figure (10);
plot(vacanze_effettive, "r"); 
hold on;
plot (vacanze, "black"); 
hold on; 
plot(errore_mm_somma, "b"); 
legend("vacanze che corrispondono", "tutte vacanze", "errore" )
title('ricerca di vacanze che corrispondono a picchi negativi');


figure(11);
plot(errore_mm_somma);
hold on;
plot(vacanze_effettive);
hold on;
plot(errore_con_medie, "black");
legend("errore", "vacanze che corrispondono", "errore con medie")
title("calcolo media di errori nel intervallo di inizio:fine vacanza");


%% parte in cui cerco di incollare stime (Y_hat) e errore e valutare migliorie
errore_usabile=errore_con_medie/2; %perchè ho sommato due errori prima
save('dati_vacanze_generiche.mat','errore_usabile');
errore_usabile=[errore_usabile' (errore_con_medie/2)']';

figure(12)
plot(-errore); 
hold on; 
plot(errore_usabile);
legend("errore", "modello dell'errore")
title("confronto tra errore e modello");

Y_hat_new=Y_hat+errore_usabile;
%prendo dati - Y_hat_new e considero solo parte in cui questo è<0 (quelli
%corrispondenti a>0 sono causati da sovraproduzione e non sottoproduzione)
errore_finale=dati(:,3)-Y_hat_new;
errore_finale=errore_finale.*rowsToDelete;

errore_finale_minore_di_0 = errore_finale.*double(errore_finale<0);
errore_iniziale_minore_di_0=-errore.*double(errore<0);

%{
%% non ho sinceramente idea perchè ho fatto sta cosa 
%calcolo la media dell'errore iniziale considerando solo picchi negativi
mse_iniziale = immse(errore_iniziale_minore_di_0, zeros(730,1));
mse_finale = immse(errore_finale_minore_di_0, zeros(730,1));
%}
mse_iniziale_=immse(errore, zeros(730,1));
mse_finale_=immse(errore_finale, zeros(730,1))

mean_iniziale = mean(errore_iniziale_minore_di_0);
mean_finale=mean(errore_finale_minore_di_0);


figure(13)
plot(dati(:,3))
hold on
plot(Y_hat_new, "LineWidth", 2)
legend("dati","stima giusta")
title("modello finito con vacanze 'in mezzo'");



