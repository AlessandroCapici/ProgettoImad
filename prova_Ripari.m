%% Pulizia
clear all
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

emptyRows=flip(emptyRows);  % Rimuovo i NaN a partire dalla fine se no mi scalano gli indici e rimuovo righe non NaN
for i=emptyRows
    dati(i,:)=[]; 
end
%% Variabili utili
dayOfYear = dati(:,1);
dayOfWeek = dati(:,2);
carico = dati(:,3);
carico_n = normalize(carico);
n_dati = length(carico);

%% Prova stepwise regression

mdl = stepwiselm(dati(:,4),dati(:,3),'PEnter',0.06)
figure(1)
plot(mdl)





