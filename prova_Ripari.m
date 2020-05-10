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
carico_n = normalize(dati(:,3));
dati_n = [dati(:,1:2) carico_n dati(:,4)];
dati_r = dati_n(1:365,1:3);   

n_dati = length(carico);
X = [cos(dati_r(:,1)*2*pi/365) sin(dati_r(:,1)*2*pi/365)...
    cos(dati_r(:,1)*2*pi*2/365) sin(dati_r(:,1)*2*pi*2/365)...
    cos(dati_r(:,1)*2*pi*3/365) sin(dati_r(:,1)*2*pi*3/365)...
    cos(dati_r(:,2)*2*pi/7) sin(dati_r(:,2)*2*pi/7)...
    cos(dati_r(:,2)*2*pi*2/7) sin(dati_r(:,2)*2*pi*2/7)...
    cos(dati_r(:,2)*2*pi*3/7) sin(dati_r(:,2)*2*pi*3/7)];
x=dati(1:365,1);
y=dati(1:365,2);
%% Prova stepwise regression 1
funct=[x y x.^2 y.^2 x.*y x.^3 y.^3 (x.^2).*y x.*(y.^2)];
funct2=[asin(x*2*pi) asin(x*2*pi/365) asin(x*2*pi*2/365) asin(y*2*pi/7) asin(y*2*pi*2/7) asin(x*2*pi)];
funct2=abs(funct2);
mdl = stepwiselm(funct,carico_n(1:365))
figure(1)
plot(mdl)
%% predizione
x=dati(1:end,1);
y=dati(1:end,2);

Phi=[x y x.^2 y.^2 x.*y x.^3 y.^3 (x.^2).*y x.*(y.^2)];
Phi2=[asin(x*2*pi) asin(x*2*pi/365) asin(x*2*pi*2/365) asin(y*2*pi/7) asin(y*2*pi*2/7) asin(x*2*pi)];
Phi2=abs(Phi2);
prediction=predict(mdl,Phi);
figure(2);
plot(dati_n(:,3),'o-')
grid on
hold on
plot(prediction)


%% Prova stepwise regression 2
emptyRows2=[];
load('caricoDEday.mat')
dati = table2array(caricoDEday);
x_vec = (1:size(dati,1))';
dati =  [dati x_vec];
c=dati(:,4)';
for i=dati(:,4)'
    if eq(dati(i,2),7)  
     emptyRows2=[emptyRows2 i];
    end
    if eq(dati(i,2),1)
     emptyRows2=[emptyRows2 i];
    end
    if isnan(dati(i,3))
     emptyRows2=[emptyRows2 i];
    end
end

emptyRows2=flip(emptyRows2);  
for i=emptyRows2
    dati(i,:)=[]; 
end 

x=dati(1:261,1);
y=dati(1:261,2);

funct=[x y x.^2 y.^2 x.*y x.^3 y.^3 (x.^2).*y x.*(y.^2)];
mdl1 = stepwiselm(funct,carico_n(1:261))
figure(3)
plot(mdl1);

%% predizione
x=dati(1:end,1);
y=dati(1:end,2);

Phi=[x y x.^2 y.^2 x.*y x.^3 y.^3 (x.^2).*y x.*(y.^2)];
prediction=predict(mdl1,Phi);
figure(4);
plot(dati_n(:,3),'o-')
grid on
hold on
plot(prediction)

        
        
        