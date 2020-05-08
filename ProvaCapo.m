%% per non fare casino
clear;
clc;
close all;
%% caricamento dati
load('caricoDEday');
load = table2array(caricoDEday);

x_vec = (1:size(load,1))';
load =  [load x_vec];
%% Eliminazione dei NaN
emptyRows=[];
for i=load(:,4)'
    if isnan(load(i,3))
        emptyRows=[emptyRows i];
    end
end
emptyRows=flip(emptyRows);  
for i=emptyRows
    load(i,:)=[]; 
end
%% variabili a caso
giorni_anno = load(:,1);
carico = load(:,3);
x= (1:length(carico))';
carico_n = normalize(carico);
n = length(carico);

%%  plot dei dati
figure(1);
plot(x,carico_n,'o-');
grid on;
hold on;

%% ls model 
q=5;
Phi=[ones(728,1) x x.^2 x.^3 x.^4 x.^5 x.^6 x.^7 x.^8 x.^9 x.^10];
[thetaLS,var_theta,SSR] = stimaLS(carico_n,Phi);
carico_hat=Phi*thetaLS;
plot(x,carico_hat);
legend('dati','stima');
