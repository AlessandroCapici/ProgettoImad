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

vect=[1:34]' ;
i=8;
f=24;
dati1=[dati_detrendizzati(:,3) vect];

figure(3)
plot(dati1(i:f,2), dati1(i:f,1),'LineWidth',2);
hold on
grid on

col=2;

%% Proviamo con un modello lineare
q=8;
n=16;
matrice_validazione=zeros(6,3);
x=vect;
Phi=[ones(f-i+1,1) x(i:f)  ...
    cos(dati_detrendizzati(i:f,2)*2*pi/7) sin(dati_detrendizzati(i:f,2)*2*pi/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*2/7) sin(dati_detrendizzati(i:f,2)*2*pi*2/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*3/7) sin(dati_detrendizzati(i:f,2)*2*pi*3/7)];
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
q=9;
n=16;
x=vect;
Phi=[ones(f-i+1,1) x(i:f) x(i:f).^2  ...
    cos(dati_detrendizzati(i:f,2)*2*pi/7) sin(dati_detrendizzati(i:f,2)*2*pi/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*2/7) sin(dati_detrendizzati(i:f,2)*2*pi*2/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*3/7) sin(dati_detrendizzati(i:f,2)*2*pi*3/7)];
[thetaLS,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS;
FPE=((n+q)/(n-q)*SSR);
AIC=2*q/n+log(SSR);
MDL=log(n)*q/n+log(SSR);
matrice_validazione(2,1)=FPE;
matrice_validazione(2,2)=AIC;
matrice_validazione(2,3)=MDL;
%plot(x(i:f),carico_hat);

%% Proviamo con un modello cubico
q=10;
n=16;
x=vect;
Phi=[ones(f-i+1,1) x(i:f) x(i:f).^2 x(i:f).^3 ...
    cos(dati_detrendizzati(i:f,2)*2*pi/7) sin(dati_detrendizzati(i:f,2)*2*pi/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*2/7) sin(dati_detrendizzati(i:f,2)*2*pi*2/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*3/7) sin(dati_detrendizzati(i:f,2)*2*pi*3/7)];
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
q=11;
n=16;
x=vect;
Phi=[ones(f-i+1,1) x(i:f) x(i:f).^2 x(i:f).^3 x(i:f).^4 ...
    cos(dati_detrendizzati(i:f,2)*2*pi/7) sin(dati_detrendizzati(i:f,2)*2*pi/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*2/7) sin(dati_detrendizzati(i:f,2)*2*pi*2/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*3/7) sin(dati_detrendizzati(i:f,2)*2*pi*3/7)];
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
q=12;
n=16;
x=vect;
Phi=[ones(f-i+1,1) x(i:f) x(i:f).^2 x(i:f).^3 x(i:f).^4 x(i:f).^5 ...
    cos(dati_detrendizzati(i:f,2)*2*pi/7) sin(dati_detrendizzati(i:f,2)*2*pi/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*2/7) sin(dati_detrendizzati(i:f,2)*2*pi*2/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*3/7) sin(dati_detrendizzati(i:f,2)*2*pi*3/7)];
[thetaLS,var_theta,SSR] = stimaLS(dati_detrendizzati(i:f,3),Phi);
carico_hat=Phi*thetaLS;
FPE=((n+q)/(n-q)*SSR);
AIC=2*q/n+log(SSR);
MDL=log(n)*q/n+log(SSR);
matrice_validazione(5,1)=FPE;
matrice_validazione(5,2)=AIC;
matrice_validazione(5,3)=MDL;
plot(x(i:f),carico_hat);

%% Proviamo con un modello di sesto grado
q=13;
n=16;
x=vect;
Phi=[ones(f-i+1,1) x(i:f) x(i:f).^2 x(i:f).^3 x(i:f).^4 x(i:f).^5 x(i:f).^6 ...
    cos(dati_detrendizzati(i:f,2)*2*pi/7) sin(dati_detrendizzati(i:f,2)*2*pi/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*2/7) sin(dati_detrendizzati(i:f,2)*2*pi*2/7)...
    cos(dati_detrendizzati(i:f,2)*2*pi*3/7) sin(dati_detrendizzati(i:f,2)*2*pi*3/7)];
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

%FPE minimo per il modello di quinto grado
%AIC minimo per il modello di quinto grado
%MDL minimo per il modello di quarto grado

