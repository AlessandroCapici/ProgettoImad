% In questo script abbiamo fatto alcune prove con le serie di Fourier. Alla
% fine non abbiamo tenuto i risultati ottenuti qui.

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

for j = rowsToDelete
    dati(j,:)=[];
end

%% Normalizzo i dati
sd = std(dati(:,3));
dati(:,3)=(1/sd)*dati(:,3);

%%
n = 350;

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
title('Modello con le serie di Fourier')
xlabel('Giorni')
ylabel('Carico')

errore = Y_hat-dati(:,3);
SSRv = errore(351:end)'*errore(351:end);

figure(2)
plot(dati(:,4),errore)
grid on
title('Plot dell''errore del modello')

A=1;
B=ones(1,7)/7;
errore_mm=filter(B,A,errore);
%per tenere conto di picchi in prossimità a giorni di vacanza:
%errore_mm_somma=[errore_mm(1:365)+errore_mm(366:end)];


figure(4)
plot(dati(:,4),errore_mm)
grid on
title('Plot della media mobile su una settimana dell''errore del modello')