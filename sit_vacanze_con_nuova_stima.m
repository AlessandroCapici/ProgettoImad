%% In questo script viene gestito l'errore delle vacanze generiche con un approcio Euristico


clear
close all
clc

%% parte di caricamento dati

load('caricoDEday.mat')
dati = table2array(caricoDEday);
x_vec = (1:size(dati,1))';
dati =  [dati x_vec];

% Eliminazione dei NaN
emptyRows=[];
for i=dati(:,4)'
    if isnan(dati(i,3))
        emptyRows=[emptyRows i];
    end
end

% Stima dei dati mancanti
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

%% Rimozione dei dati in prossimità di vacanze di fine anno
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

% Plot dati normalizzati senza vacanze di Natale;
figure(1)
plot(dati(:,4), dati(:,3),'o-')
grid on
title('Dati normalizzati senza vacanze di Natale')

%% modello a cui poi sottrarre dati effettivi
% Stima del modello settimanale

Phi_tutto = [cos(2*pi*dati(:,2)/7) sin(2*pi*dati(:,2)/7)...
            cos(2*pi*dati(:,2)*2/7) sin(2*pi*dati(:,2)*2/7)...
            cos(2*pi*dati(:,2)*3/7) sin(2*pi*dati(:,2)*3/7)];
[N,q]=size(Phi_tutto);
[thetaLS,var_theta,SSR] = stimaLS(dati(:,3),Phi_tutto);
stima = Phi_tutto*thetaLS;

figure(2)
plot(dati(:,4), dati(:,3))
grid on
hold on
plot(dati(:,4),stima)
dati_new = dati;
dati_new(:,3) = dati_new(:,3)-stima;

figure(3)
plot(dati_new(:,4), dati_new(:,3), '-o')
grid on
title('Dati tolta stima settimanale')
xlabel("giorni")
ylabel("carico")


% Stima del andamento annuale usando i dat a cui e' stato tolto l'andamento settimanale
i=1;
f=700;
mdl1 = stepwiselm(dati_new(i:f,1),dati_new(i:f,3),'poly5','Criterion','aic');

Phi_anno1 = [ones(f,1) dati_new(i:f,1) dati_new(i:f,1).^2 dati_new(i:f,1).^3]; %primo anno
[N,q]=size(Phi_anno1);
[thetaLS,var_theta,SSR] = stimaLS(dati(i:f,3),Phi_anno1);
stimaanno1 = Phi_anno1*thetaLS;
[fpe,aic,mdl] = test(N,q,SSR);

stimatot=stimaanno1;
figure(4)
plot(mdl1) %funzione trovata '1 + x1 + x1^2 + x1^3 + x1^4'
hold on
plot(dati_new(:,4), dati_new(:,3),'o-')
grid on
hold on
plot(dati_new(:,4),stimatot)
title("Modello annuale senza l'andamento settimanale");


supermegastima=stima+stimatot;
%{
figure(5)
plot(dati(:,4), dati(:,3),'o-')
grid on
hold on
plot(dati(:,4),supermegastima)
title("Somma tra modelli e confronto con dati");
%}

%% parte calcolo errore da sommare a modello
% array di vacanze 
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
title('Confronto tra dati normalizzati e modello')

%per eliminare dati in prossimità di vacanze di natale
errore = Y_hat-dati(:,3);
rowsToDelete=zeros(730,1)+1;
for i=dati(:,4)'
   if dati(i,1)<7 || dati(i,1)>356
       rowsToDelete(i)=0; %imposto righe da eliminare in posizione i a 0
   end
end
errore=rowsToDelete.*errore;

figure(7)
plot(dati(:,4),-errore)
grid on
title("errore tra giorni dell'anno 7 e 356");
xlabel("giorno");
ylabel("errore");


% somma del errore tra due anni e calcolo di media mobile su 7 giorni per
% "appiattirlo": vacanze vicine ma a distanza di 7 giorni conteranno di più.
A=1;
B=ones(1,7)/7;
errore_mm=filter(B,A,errore);
errore_mm_somma=[errore_mm(1:365)+errore_mm(366:end)];
%per girare l'errore dato che ora sono invertiti
errore_mm_somma = -errore_mm_somma;
figure(8);
plot (errore_mm_somma)
title("media mobile su 7 giorni di errore sommato tra i due anni");
grid on;
xlabel("giorno");
ylabel("errore");

%rimozione del errore maggiore di -0.1 (considerando dati normalizzati)
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

%calcolo della media dell'errore
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

% eliminazione di vacanze effettive (prese dai dati) che non hanno un 
% corrispettivo nel array di vacanze
vacanze_effettive=zeros(365,1);
for i = 1:365
    if (vacanze(i)~=0)
        if(abs(errore_mm_somma_pulito(i))==vacanze(i))
            vacanze_effettive(i)=0.5;
        end
    end
end

% pulizia di media dell'errore solo in prossimità di vacanze effettive 
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
plot(vacanze_effettive, "red"); 
hold on;
plot (vacanze, "black"); 
hold on; 
grid on;
plot(errore_mm_somma, "b"); 
legend("vacanze effettive", "tutte le vacanze", "errore" )
title('ricerca di vacanze che corrispondono a picchi negativi');
xlabel("giorni")
ylabel("errore");


figure(11);
plot(errore_mm_somma);
hold on;
plot(vacanze_effettive);
hold on;
grid on;
plot(errore_con_medie, "black");
legend("errore", "vacanze che corrispondono", "errore con medie")
title("calcolo media di errori nel intervallo di inizio:fine vacanza")
xlabel("giorni")
ylabel("errore");


%% tentativo di incollare stima (Y_hat) e errore e valutare migliorie
errore_usabile=errore_con_medie/2; %perchè errore_con_medie è una somma su giorni
save('dati_vacanze_generiche.mat','errore_usabile');
errore_usabile=[errore_usabile' (errore_con_medie/2)']';

figure(12)
plot(-errore); 
hold on; 
grid on;
plot(errore_usabile);
legend("errore", "modello dell'errore")
title("confronto tra errore e modello");
xlabel("giorni");
ylabel("errore");

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



