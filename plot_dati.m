clear
close all

load('caricoDEday.mat')
dati = table2array(caricoDEday);

x_vec=(1:size(dati))';
dati = [dati x_vec];
%% Plot di tutti i dati
figure(1)
plot(dati(:,3),'o-')
grid on
title('Plot dei dati')

%% Plot dei dati divisi per giorno della settimana
dati_dom=[];
dati_lun=[];
dati_mar=[];
dati_mer=[];
dati_gio=[];
dati_ven=[];
dati_sab=[];

for i=1:size(dati)
   switch(dati(i,2))
       case 1
           dati_dom=[dati_dom; dati(i,:)];
       case 2
           dati_lun=[dati_lun; dati(i,:)];
       case 3
           dati_mar=[dati_mar; dati(i,:)];
       case 4
           dati_mer=[dati_mer; dati(i,:)];
       case 5
           dati_gio=[dati_gio; dati(i,:)];
       case 6
           dati_ven=[dati_ven; dati(i,:)];
       case 7
           dati_sab=[dati_sab; dati(i,:)];
   end
end

figure(2)
plot(dati_lun(:,4),dati_lun(:,3),'o-')
grid on
hold on
plot(dati_mar(:,4),dati_mar(:,3),'o-')
plot(dati_mer(:,4),dati_mer(:,3),'o-')
plot(dati_gio(:,4),dati_gio(:,3),'o-')
plot(dati_ven(:,4),dati_ven(:,3),'o-')
plot(dati_sab(:,4),dati_sab(:,3),'o-')
plot(dati_dom(:,4),dati_dom(:,3),'o-')

legend('Lunedi', 'Martedi', 'Mercoledi','Giovedi','Venerdi','Sabato','Domenica')
title('Dati collegati in base al giorno della settimana')
% Se si vogliono vedere i dati relativi a un unico giorno della settimana
% basta commentare le linee di codice dei plot che non si vogliono vedere


%% Plot 3D usando sugli assi giorno della settimana e giorno dell'anno

figure(3)
plot3(dati(:,1), dati(:,2), dati(:,3),'o')
xlabel('Giorno dell''anno')
ylabel('Giorno della settimana')
zlabel('Consumo energetico')
grid on
