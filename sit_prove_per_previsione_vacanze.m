clear
close all
clc
warning('off','all')

%% modellino usa l'array sotto per stabilire giorni di vacanza e li sovrappone all'errore
%% (errore trovato come dati detrendizzati meno stima calcolata 
%% per trovare giorni effettivi di vacanza. poi calcola media di errore su quel intervallo

%% festività tedesche, grossomodo
% https://www.studying-in-germany.org/public-holidays-germany/
vacanze=zeros(365,1);
%%                   1/01  6/01, 24/02, 10/03, 13/03, 1/05, 10/05, 21/05, 30/05, 11/06, 15/08, 19/09, 3/10, 31/10, 18/11, 25/12
giorni_vacanze = [   1,   6,    55,  130,   141,    151,  162,   227,   262,   276,  304,  322,   359];
%rimosso quelli che facevano casini sono 100 103 114 121
vacanze (giorni_vacanze) = 1;


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

mean_year1 = mean(dati(1:365,3));
mean_year2 = mean(dati(366:end,3));

vec=[mean_year1*ones(365,1); mean_year2*ones(365,1)];

dati(:,3) = dati(:,3)-vec;

%% Pulizia vacanze natalizie

rowsToDelete = [];
for i=dati(:,4)'
   if dati(i,1)<7 | dati(i,1)>356
       rowsToDelete = [rowsToDelete i];
   end
end

rowsToDelete = flip(rowsToDelete);

% for j = rowsToDelete
%     dati(j,:)=[];
% end

%% Normalizzo i dati
sd = std(dati(:,3));
dati(:,3)=(1/sd)*dati(:,3);

%%
n = 700;

Phi = [ones(n,1) ...
    cos(dati(1:n,1)*2*pi/365) sin(dati(1:n,1)*2*pi/365)...
    cos(dati(1:n,1)*2*pi*2/365) sin(dati(1:n,1)*2*pi*2/365)...
    ...cos(dati(1:n,1)*2*pi*3/365) sin(dati(1:n,1)*2*pi*3/365)...
   ... cos(dati(1:n,1)*2*pi*4/365) sin(dati(1:n,1)*2*pi*4/365)...
    cos(dati(1:n,2)*2*pi/7) sin(dati(1:n,2)*2*pi/7)...
    cos(dati(1:n,2)*2*pi*2/7) sin(dati(1:n,2)*2*pi*2/7)...
    cos(dati(1:n,2)*2*pi*3/7) sin(dati(1:n,2)*2*pi*3/7)...
    cos(dati(1:n,2)*2*pi*4/7) sin(dati(1:n,2)*2*pi*4/7)];

[thetaLS,var_theta,SSR] = stimaLS(dati(1:n,3),Phi);

n=size(dati,1);
Phi_p =  [ones(n,1) ...
    cos(dati(1:n,1)*2*pi/365) sin(dati(1:n,1)*2*pi/365)...
    cos(dati(1:n,1)*2*pi*2/365) sin(dati(1:n,1)*2*pi*2/365)...
   ... cos(dati(1:n,1)*2*pi*3/365) sin(dati(1:n,1)*2*pi*3/365)...
  ...  cos(dati(1:n,1)*2*pi*4/365) sin(dati(1:n,1)*2*pi*4/365)...
    cos(dati(1:n,2)*2*pi/7) sin(dati(1:n,2)*2*pi/7)...
    cos(dati(1:n,2)*2*pi*2/7) sin(dati(1:n,2)*2*pi*2/7)...
    cos(dati(1:n,2)*2*pi*3/7) sin(dati(1:n,2)*2*pi*3/7)...
    cos(dati(1:n,2)*2*pi*4/7) sin(dati(1:n,2)*2*pi*4/7)];

Y_hat = Phi_p * thetaLS;

figure(1)
plot(dati(:,4),dati(:,3))
hold on
plot(dati(:,4),Y_hat)
grid on
legend('Dati','Stima')
title('dati normalizzati e modello')



errore = Y_hat-dati(:,3);
%devo limitare range di errore tra 14 e 356
rowsToDelete=zeros(730,1)+1; %vettore di 1
for i=dati(:,4)'
   if dati(i,1)<14 || dati(i,1)>356
       rowsToDelete(i)=0; %imposto righe da eliminare in posizione i a 0
   end
end
errore=rowsToDelete.*errore;

figure(2)
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
figure(3);
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

figure(4)
plot(errore_con_medie, "blue")
hold on
plot(per_fare_una_media_appiattito, "green", "LineWidth", 2);
hold on
plot(vacanze_effettive)
title("errore medio solo in prossimità di vacanze effettive");


errore_con_medie=per_fare_una_media_appiattito;




%{
for i=1:length(errore_con_medie)
    if errore_con_medie(i)<0 && inizio==0
        inizio=i;
        fprintf("impostato inizio a %i\n",inizio);
    end
    if vacanze_effettive(i)>0
        flag=true;
        fprintf("impostato a true. TROVATO PICCO\n");
    end
    if errore_con_medie(i)==0 && inizio>0 
        fprintf("errore con medie\n");
        if flag==false %allora devo appiattire da inizio a qui
            fprintf("flag è un false. appiattisco da:%i a %i\n",inizio, i);
            per_fare_una_media_appiattito(inizio:i)=0;
            inizio=0;
        else 
            fprintf("impostato flag a false\n");
            flag=false;
        end
    end
end
%}

figure (5);
plot(vacanze_effettive, "r"); 
hold on;
plot (vacanze, "black"); 
hold on; 
plot(errore_mm_somma, "b"); 
legend("vacanze che corrispondono", "tutte vacanze", "errore" )
title('ricerca di vacanze che corrispondono a picchi negativi');


figure(6);
plot(errore_mm_somma);
hold on;
plot(vacanze_effettive);
hold on;
plot(errore_con_medie, "black");
legend("errore", "vacanze che corrispondono", "errore con medie")
title("calcolo media di errori nel intervallo di inizio:fine vacanza");


%% parte in cui cerco di incollare stime (Y_hat) e errore e valutare migliorie
errore_usabile=errore_con_medie/2; %perchè ho sommato due errori prima
errore_usabile=[errore_usabile' (errore_con_medie/2)']';

figure(7)
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
%calcolo la media dell'errore iniziale considerando solo picchi negativi
errore_iniziale_minore_di_0=errore.*double(errore<0);
mse_iniziale = immse(errore_iniziale_minore_di_0, zeros(730,1));
mse_finale = immse(errore_finale_minore_di_0, zeros(730,1));

mean_iniziale = mean(errore_iniziale_minore_di_0);
mean_finale=mean(errore_finale_minore_di_0);
figure(8)
title("ciao mondo")
plot(dati(:,3))
hold on
plot(Y_hat_new)
legend("dati","stima giusta")

