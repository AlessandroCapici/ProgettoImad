clear
close all
clc
warning('off','all')

%% modellino usa l'array sotto per stabilire giorni di vacanza e li sovrappone a dati su errore dati meno stima
%% per trovare giorni effettivi di vacanza. poi calcola media di errore su quel intervallo

%% festività tedesche, grossomodo
% https://www.studying-in-germany.org/public-holidays-germany/
vacanze=zeros(365,1);
%%                   1/01  6/01, 24/02, 10/03, 13/03, 1/05, 10/05, 21/05, 30/05, 1/06, 11/06, 15/08, 19/09, 3/10, 31/10, 1/11, 18/11, 25/12
giorni_vacanze = [   1,   6,    55,    100,   103,  114,  121,  130,   141,    151,   152,  162,   227,   262,   276,  304,   305,  322,   359];
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

errore = Y_hat-dati(:,3);

figure(2)
plot(dati(:,4),errore)
grid on

A=1;
B=ones(1,7)/7;
errore_mm=filter(B,A,errore);
%per tenere conto di picchi in prossimità a giorni di vacanza:
errore_mm_somma=[errore_mm(1:365)+errore_mm(366:end)];
%per girare l'errore dato che ora sono invertiti
errore_mm_somma = -errore_mm_somma;
figure(3);
title("media mobile di errore su finestra di 7 giorni");
plot (errore_mm_somma);
%per pulire dati sostituisco con 0 elementi che meno si allontanano.
errore_mm_somma_pulito = zeros(365,1);

for i = 1:365
    if (abs(errore_mm_somma(i)) < 0.2)
        errore_mm_somma_pulito(i)=0;
        continue;
    end
    if(errore_mm_somma(i) < -0.2)
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

figure (5);
plot(vacanze_effettive, "r"); 
hold on;
plot (vacanze, "black"); 
hold on; 
plot(errore_mm_somma, "b"); 
legend("vacanze", "tutte vacanze", "errore" );


figure(6);
plot(errore_mm_somma);
hold on;
plot(errore_mm_somma_pulito);
hold on;
plot(errore_con_medie, "black");
legend("errore", "errore pulito", "errore con medie");


figure(4)
plot(dati(:,4),errore_mm)
grid on
