%% per non fare casino
clear;
close all;
%% caricamento dati
load('caricoDEday');
load = table2array(caricoDEday);
%% variabili a caso
dayOfYear = load(:,1);
dayOfWeek = load(:,2);
carico = load(:,3);
x= (1:length(carico))';
carico_n = normalize(carico);
n_dati = length(carico);

%%  plot dei dati
figure(1);
scatter(x,carico,'v');
plot(load);

