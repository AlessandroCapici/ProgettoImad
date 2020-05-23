% Script per stimare tutti i dati e fare il grafico di dati veri e stime
% usando la funzione prediz

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

%% Plot dei dati
figure(1)
plot(dati(:,4), dati(:,3),'b')
grid on
hold on

%% Stima
mean_year1 = mean(dati(1:365,3));
mean_year2 = mean(dati(366:end,3));
crescita = mean_year2-mean_year1;

X = dati(:,1:2);
X1 = [(1:365)' zeros(365,1)];
X = [X; X1];

% Calcolo del giorno della settimana per il terzo anno
for i = 731:1095
    g=mod(X(i,1),7);
    if g<4
        X(i,2) = g+4;
    else
        X(i,2) = g-3;
    end
end

stima = zeros(1095,1);

%stima = zeros(730,1);

for i = 1:1095
%for i = 1:730
    stima(i)=prediz(X(i,1),X(i,2));
    if i<=365*2
        stima(i) = stima(i)-crescita;
    end
    if i<=365
        stima(i) = stima(i)-crescita;
    end
end

plot((1:1095),stima,'r')
%plot((1:730),stima,'r')
legend('Dati', 'Stima')
title('Stima finale')
xlabel('Giorno')
ylabel('Carico')
