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
%% variabili
dati=load(:,3);
x=normalize(dati);
giorni_settimana = load(1:end,2);

%% cluser dei dati
[idx,ctrs,sumd]= kmeans(x,4);
gscatter(giorni_settimana,x,idx);
legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Centroids');
hold off;



