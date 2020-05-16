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

vect=[1:34]' ;
i=8;
f=24;
dati1=[dati_detrendizzati(:,3) vect];

figure(1)
plot(dati1(i:f,2), dati1(i:f,1));
hold on
grid on

col=2;

%% Proviamo con un modello polinomiale
x=vect;
Phi=[ones(f-i+1,1)  x(i:f) x(i:f).^2  ...
    cos(dati_detrendizzati(i:f,2)*2*pi/7) sin(dati_detrendizzati(i:f,2)*2*pi/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*2/7) sin(dati_detrendizzati(i:f,2)*2*pi*2/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*3/7) sin(dati_detrendizzati(i:f,2)*2*pi*3/7)];
[thetaLS,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS;
plot(x(i:f),carico_hat);
