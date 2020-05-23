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

%% Stima del trend lineare

Phi = [ones(size(dati,1),1) dati(:,4)];
thetaLS = Phi\dati(:,3);

trend = Phi*thetaLS;
figure(1)
plot(dati(:,3),'o-')
hold on
plot(trend)
grid on
legend('dati','trend lineare')

figure(2)
plot(dati(:,3)-trend,'-o')
grid on
title("Eliminazione del trend lineare")
xlabel('Giorni')
ylabel('Consumi')


%% Trend come media annuale


mean_year1 = mean(dati(1:365,3));
mean_year2 = mean(dati(366:end,3));

vec=[mean_year1*ones(365,1); mean_year2*ones(365,1)];

dati1=dati;
dati1(:,3) = dati1(:,3)-vec;

figure(3)
plot(dati1(:,3))
grid on
title('Dati a cui viene sottratta la media annuale')

% Questa è la versione che ci piace di più

%% Trend dalla media mobile

A=1;
B=ones(1,7)/7;
y_mediamobile=filter(B,A,dati(:,3));

sum=0;
for i=1:7
   sum = sum + dati(i,3);
   y_mediamobile(i)=sum/i;
end

thetaLS_mm = Phi\y_mediamobile;
trend1 = Phi*thetaLS_mm;
figure(4)
plot(y_mediamobile,'o-')
hold on
plot(trend1)
grid on
legend('Media mobile dei dati', 'Trend lineare stimato sulla media mobile')

figure(5)
plot(dati(:,3)-trend1)
grid on
title('Dati a cui e'' stato sottratto il trend stimato sulla media mobile')