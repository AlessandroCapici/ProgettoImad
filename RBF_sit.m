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
giorni_anno = load(1:end,2);
carico = load(1:end,3);
x= (1:length(carico))';
carico_n = normalize(carico)';
n = length(carico);
in=[x , giorni_anno]';
%% Creo la rete neurale
nnetwork=fitnet([20,20,20]);
...Size of the hidden layers in the network, specified as a row vector. 
...The length of the vector determines the number of hidden layers in the network.
...Example: For example, you can specify a network with 3 hidden layers, 
...where the first hidden layer size is 10, the second is 8, and the third is 5 as follows: [10,8,5]
...The input and output sizes are set to zero. The software adjusts the sizes of these during training according to the training data.

%% Setto alcuni parametri
nnetwork.trainParam.show=50;
nnetwork.trainParam.lr=0.1;    %li ho copiati da internet ahahha
nnetwork.trainParam.epochs=300;
net.trainParam.min_grad = 1e-5;




%% SCOPRO QUANTO FIGO E' IL MODELLO 
% array con tutti tipi di modello
reti = {'trainlm', 'trainbr', 'trainbfg', 'trainrp', 'trainscg', 'traincgb', 'traincgf', 'traincgp', 'trainoss', 'traingdx', 'traingdm', 'traingd'};
% devo fare loop N volte per trovare array MSE di ciascun tipo di modello
N=10;
contatore =0;
% mse_matrix terrà valori mse calcolati per ogni tipo di modello
mse_matrix = zeros(length(reti),N);
for iteratore_reti = 1:length(reti)
    for c = 1:N
        %% Fase di learning
        nnetwork=fitnet([20,20,20], char(reti(iteratore_reti))); %devo coppiare questo valore altrimenti nnetwork non cambia
        nnetwork=train(nnetwork,in,carico_n); 
        simulazione=sim(nnetwork,in);
        %% fase di calcolo MSE
        mse_matrix (iteratore_reti, c) = [ mse(nnetwork, carico_n, simulazione, 5)];
        
        % stampo per comodità iterazione : totale_iterazioni
        contatore = contatore+1;
        disp (['iterazione: ' num2str(contatore) ' di ' num2str(N*length(reti))]);
    end
end



% calcolo media di ogni MSE ordinati in base a modello
mse_avg = [];
mse_avg = [mse_avg reti'];
mse_avg = [mse_avg string(mean(mse_matrix')')]


%% da qui in poi calcolo di un modello 

%% Fase di learning
nnetwork=train(nnetwork,in,carico_n); 
simulazione=sim(nnetwork,in);
figure(1);
%plot(simulazione);
grid on;
hold on;
plot(carico_n);
hold on;
%legend('simulazione','dati');
legend('dati');
%% Fase di test
carico_test=load(1:end,3);
carico_test=normalize(carico_test)';
giorni_anno_test = load(1:end,2);
x_test=(1:length(carico_test))';
in_test=[x_test,giorni_anno_test]';
simtest=sim(nnetwork,in_test);
figure(2);
grid on;
hold on;
plot(simtest);
hold on;
plot(carico_test);
legend('simulazione','dati');
%% plot errore
figure(3);

errortraining= simulazione-carico_n;
errortest= simtest-carico_n;
plot (errortraining, 'black');
mse(nnetwork, carico_n, simulazione, 5)
legend('error training','error test');


