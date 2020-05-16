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


for i = emptyRows
    dati(i,3)= (dati(i-7,3)+dati(i+7,3))/2;
end


%% Media mobile
A=1;
B=ones(1,7)/7;
y_mediamobile=filter(B,A,dati(:,3));

sum=0;
for i=1:7
   sum = sum + dati(i,3);
   y_mediamobile(i)=sum/i;
end

mm = [dati(:,1) dati(:,4) y_mediamobile];


%% Pulizia vacanze natalizie

rowsToDelete = [];
for i=mm(:,2)'
   if mm(i,1)<7 | mm(i,1)>356
       rowsToDelete = [rowsToDelete i];
   end
end

rowsToDelete = flip(rowsToDelete);

for j = rowsToDelete
    mm(j,:)=[];
end

%% Plot di tutti i dati
figure(1)
plot(dati(:,3),'o-')
grid on
title('Plot brutale dei dati')

%% Plot della media mobile

figure(2)
plot(mm(:,2),mm(:,3))
grid on
title('Plot della media mobile senza Natale')

%% Plot dati a cui ho tolto la media mobile

figure(3)
plot(dati(:,3)-y_mediamobile,'o-')
grid on
