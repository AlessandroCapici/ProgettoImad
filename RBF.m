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
figure(1)
gscatter(giorni_settimana,x,idx);
hold on
X = [0.7 7.3];
plot(X,[ctrs(1) ctrs(1)])
plot(X,[ctrs(2) ctrs(2)])
plot(X,[ctrs(3) ctrs(3)])
plot(X,[ctrs(4) ctrs(4)])
legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Centroid 1','Centroid 2',...
    'Centroid 3', 'Centroid 4');
hold off
title('Dati divisi per cluster e giorno della settimana')

figure(2)
gscatter(load(:,4),x,idx)
legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4');
grid on
title('Dati plottati nel tempo e divisi per cluster')

