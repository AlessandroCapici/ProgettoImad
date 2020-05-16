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

%% Normalizzo i dati
sd = std(dati(:,3));
dati(:,3)=(1/sd)*dati(:,3);

%% Tolgo il trend

mean_year1 = mean(dati(1:365,3));
mean_year2 = mean(dati(366:end,3));

vec=[mean_year1*ones(365,1); mean_year2*ones(365,1)];

dati_detrendizzati=dati;
dati_detrendizzati(:,3) = dati_detrendizzati(:,3)-vec;

figure(1)
plot(dati_detrendizzati(:,3))
grid on

%% Tengo solo le vacanze di Natale
rowsToDelete = [];
for i=dati_detrendizzati(:,4)'
   if dati_detrendizzati(i,1)>14 && dati_detrendizzati(i,1)<356
       rowsToDelete = [rowsToDelete i];
   end
end

rowsToDelete = flip(rowsToDelete);

for j = rowsToDelete
     dati_detrendizzati(j,:)=[];
end

vect=[1:48]' ;

dati1=[dati_detrendizzati(:,3) vect];

figure(2)
plot(dati1(:,2), dati1(:,1));

dati_n=normalize(dati_detrendizzati(:,3));

%% Proviamo con un modello polinomiale
q=5;
x=vect;
Phi=[ones(48,1) x x.^2 x.^3 x.^4 x.^5 x.^6 x.^7 x.^8 x.^9 x.^10];
[thetaLS,var_theta,SSR] = stimaLS(dati_n,Phi);
carico_hat=Phi*thetaLS;
figure(3)
plot(dati1(:,2), dati1(:,1));
hold on
plot(x,carico_hat);


