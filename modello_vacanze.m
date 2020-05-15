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

%% Tengo solo le vacanze di Natale
rowsToDelete = [];
for i=dati(:,4)'
   if dati(i,1)>7 && dati(i,1)<356
       rowsToDelete = [rowsToDelete i];
   end
end

rowsToDelete = flip(rowsToDelete);

for j = rowsToDelete
     dati(j,:)=[];
end

vect=[1:34]' ;
dati1=[dati(:,3) vect];

figure(1)
plot(dati1(:,2), dati1(:,1) );

