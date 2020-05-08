clear
close all

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

emptyRows=flip(emptyRows);
for i=emptyRows
    dati(i,:)=[]; 
end

carico_n = normalize(dati(:,3));
dati_n = [dati(:,1:2) carico_n dati(:,4)];

%% Calcolo del modello
dati_r = dati_n(1:365,1:3);   


X = [cos(dati_r(:,1)*2*pi/365) sin(dati_r(:,1)*2*pi/365)...
    cos(dati_r(:,1)*2*pi*2/365) sin(dati_r(:,1)*2*pi*2/365)...
    cos(dati_r(:,1)*2*pi*3/365) sin(dati_r(:,1)*2*pi*3/365)...
    cos(dati_r(:,2)*2*pi/7) sin(dati_r(:,2)*2*pi/7)...
    cos(dati_r(:,2)*2*pi*2/7) sin(dati_r(:,2)*2*pi*2/7)...
    cos(dati_r(:,2)*2*pi*3/7) sin(dati_r(:,2)*2*pi*3/7)];

mdl = stepwiselm(X,dati_r(:,3),'constant');

%% Predizione del modello

Phi = [cos(dati_n(1:end,1)*2*pi/365) sin(dati_n(1:end,1)*2*pi/365)...
    cos(dati_n(1:end,1)*2*pi*2/365) sin(dati_n(1:end,1)*2*pi*2/365)...
    cos(dati_n(1:end,1)*2*pi*3/365) sin(dati_n(1:end,1)*2*pi*3/365)...
    cos(dati_n(1:end,2)*2*pi/7) sin(dati_n(1:end,2)*2*pi/7)...
    cos(dati_n(1:end,2)*2*pi*2/7) sin(dati_n(1:end,2)*2*pi*2/7)...
    cos(dati_n(1:end,2)*2*pi*3/7) sin(dati_n(1:end,2)*2*pi*3/7)];

ypred = predict(mdl,Phi);

figure(1)
plot(dati_n(:,3),'o-')
grid on
hold on
plot(ypred)