% Script che calcola i parametri dei modelli e li salva in un file che poi
% viene usato dalla funzione prediz.
% La complessità e il tipo di modello sono state scelte nel file Progetto.m

close all
clear

%% Caricamento dati
load('caricoDEday.mat')
dati = table2array(caricoDEday);

x_vec = (1:size(dati,1))';
dati =  [dati x_vec];
%% Eliminazione dei NaN e stima dei dati mancanti
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

%% De-trendizzazione
mean_year1 = mean(dati(1:365,3));
mean_year2 = mean(dati(366:end,3));

% Abbiamo supposto che la media fosse in crescita anche per il terzo anno,
% quello su cui vengono fatte le previsioni. Inoltre abbiamo supposto che
% la crescita tra il secondo e il terzo anno fosse uguale alla crescita tra
% il primo e il secondo anno.
% Sapendo la media dei consumi del terzo anno sarebbe possibile sostituirla
% alla meedia calcolata da noi e ottenere delle previsioni migliori.
mean_year3 = mean_year2 + (mean_year2-mean_year1);
media = mean_year3;

vec=[mean_year1*ones(365,1); mean_year2*ones(365,1)];

dati(:,3) = dati(:,3)-vec;

%% Normalizzo i dati
sd = std(dati(:,3));
dati(:,3)=(1/sd)*dati(:,3);

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

%% Modello settimanale
Phi_w = [cos(2*pi*dati(:,2)/7) sin(2*pi*dati(:,2)/7)...
    cos(2*pi*dati(:,2)*2/7) sin(2*pi*dati(:,2)*2/7)...
    cos(2*pi*dati(:,2)*3/7) sin(2*pi*dati(:,2)*3/7)];
[thetaLS_w,~,~] = stimaLS(dati(:,3),Phi_w);
stima = Phi_w*thetaLS_w;

%% MOdello annuale
dati_new = dati;
dati_new(:,3) = dati_new(:,3)-stima;

i=1;
f=size(dati_new,1);

Phi_y = [ones(f,1) dati_new(i:f,1) dati_new(i:f,1).^2 dati_new(i:f,1).^3];
[thetaLS_y,~,~] = stimaLS(dati(i:f,3),Phi_y);

%% Salvataggio dati

save parametri_modello_annuale.mat thetaLS_y thetaLS_w sd media