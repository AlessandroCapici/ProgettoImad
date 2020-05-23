% Stimiamo un modello a parte per le vacanze di Natale. In questo modello
% non teniamo conto del giorno della settimana perch� ci sembra pi�
% significativa l'informazione contenuta nel giorno dell'anno. Proviamo a
% usare modelli polinomiali di vari gradi.

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
figure(1)
plot(dati(:,4), dati(:,3))
%% Normalizzo i dati
sd = std(dati(:,3));
dati(:,3)=(1/sd)*dati(:,3);

%% Tolgo il trend

mean_year1 = mean(dati(1:365,3));
mean_year2 = mean(dati(366:end,3));

vec=[mean_year1*ones(365,1); mean_year2*ones(365,1)];

dati_detrendizzati=dati;
dati_detrendizzati(:,3) = dati_detrendizzati(:,3)-vec;
figure(2)
plot(dati_detrendizzati(:,4), dati_detrendizzati(:,3))
%% Tengo solo le vacanze di Natale
rowsToDelete = [];
for i=dati_detrendizzati(:,4)'
   if dati_detrendizzati(i,1)>7 && dati_detrendizzati(i,1)<356
       rowsToDelete = [rowsToDelete i];
   end
end

rowsToDelete = flip(rowsToDelete);

for j = rowsToDelete
     dati_detrendizzati(j,:)=[];
end

figure(3)
i=8;
f=24;
x=[1:17]';
plot(x, dati_detrendizzati(i:f,3),'LineWidth',2);
hold on
grid on

%% Proviamo con un modello lineare
q=2;
n=17;
matrice_validazione=zeros(6,3);
Phi=[ones(17,1) x];
[thetaLS,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS;
FPE=((n+q)/(n-q)*SSR);
AIC=2*q/n+log(SSR);
MDL=log(n)*q/n+log(SSR);
matrice_validazione(1,1)=FPE;
matrice_validazione(1,2)=AIC;
matrice_validazione(1,3)=MDL;
%plot(x(i:f),carico_hat);


%% Proviamo con un modello quadratico
q=3;
n=17;
Phi=[ones(17,1) x x.^2];
[thetaLS_vacanze,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS_vacanze;
FPE=((n+q)/(n-q)*SSR);
AIC=2*q/n+log(SSR);
MDL=log(n)*q/n+log(SSR);
matrice_validazione(2,1)=FPE;
matrice_validazione(2,2)=AIC;
matrice_validazione(2,3)=MDL;
plot(x,carico_hat);

%% Proviamo con un modello cubico
q=4;
n=17;
Phi=[ones(17,1) x x.^2 x.^3];
[thetaLS,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS;
FPE=((n+q)/(n-q)*SSR);
AIC=2*q/n+log(SSR);
MDL=log(n)*q/n+log(SSR);
matrice_validazione(3,1)=FPE;
matrice_validazione(3,2)=AIC;
matrice_validazione(3,3)=MDL;
%plot(x(i:f),carico_hat);

%% Proviamo con un modello di quarto grado
q=5;
n=17;
Phi=[ones(17,1) x x.^2 x.^3 x.^4];
[thetaLS,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS;
FPE=((n+q)/(n-q)*SSR);
AIC=2*q/n+log(SSR);
MDL=log(n)*q/n+log(SSR);
matrice_validazione(4,1)=FPE;
matrice_validazione(4,2)=AIC;
matrice_validazione(4,3)=MDL;
%plot(x(i:f),carico_hat);

%% Proviamo con un modello di quinto grado
q=6;
n=17;
Phi=[ones(17,1) x x.^2 x.^3 x.^4 x.^5];
[thetaLS,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS;
FPE=((n+q)/(n-q)*SSR);
AIC=2*q/n+log(SSR);
MDL=log(n)*q/n+log(SSR);
matrice_validazione(5,1)=FPE;
matrice_validazione(5,2)=AIC;
matrice_validazione(5,3)=MDL;
%plot(x(i:f),carico_hat);

%% Proviamo con un modello di sesto grado
q=7;
n=17;
Phi=[ones(17,1) x x.^2 x.^3 x.^4 x.^5 x.^6];
[thetaLS,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS;
FPE=((n+q)/(n-q)*SSR);
AIC=2*q/n+log(SSR);
MDL=log(n)*q/n+log(SSR);
matrice_validazione(6,1)=FPE;
matrice_validazione(6,2)=AIC;
matrice_validazione(6,3)=MDL;
%plot(x(i:f),carico_hat);

figure(4)
grid on
plot(dati(1:6,4),matrice_validazione(:,1))
title('fpe')

figure(5)
grid on
plot(dati(1:6,4),matrice_validazione(:,2))
title('aic')

figure(6)
grid on
plot(dati(1:6,4),matrice_validazione(:,3))
title('mdl')


% save parametri_modello_vacanzeNatale.mat thetaLS_vacanze