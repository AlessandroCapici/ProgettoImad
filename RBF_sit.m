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




%% creazione di array riassuntivo di modello migliore basandosi su funzione di training
% array con tutti tipi di funzioni di training
reti = {'trainlm', 'trainbr', 'trainbfg', 'trainrp', 'trainscg', 'traincgb', 'traincgf', 'traincgp', 'trainoss', 'traingdx', 'traingdm', 'traingd'};
% devo fare loop N volte per trovare array MSE di ciascun tipo di funzione
N=2;
contatore =0;
%creo mse minimo e massimo per poter tenere conto di risultati estremi
mse_minimo=zeros(12,1);
%creo array di network per poter tenere conto di network migliore
nnetwork_array = cell(12,1);
% mse_matrix terrà valori mse calcolati per ogni tipo di funzione
mse_matrix (1:length(reti), 1:N)=100;
for iteratore_reti = 1:length(reti)
    for c = 1:N
        % stampo per comodità iterazione rispetto il totale di iterazioni
        contatore = contatore+1;
        disp (['iterazione: ' num2str(contatore) ' di ' num2str(N*length(reti))]);
        %% Fase di learning
        nnetwork=fitnet([20,20,20], char(reti(iteratore_reti))); %devo coppiare questo valore altrimenti nnetwork non cambia
        nnetwork=train(nnetwork,in,carico_n); 
        simulazione=sim(nnetwork,in);
        %% fase di calcolo MSE
        mse_current=mse(nnetwork, carico_n, simulazione, 5);
        mse_matrix (iteratore_reti, c) = mse_current;
        %se mse corrente è il minimo nell'array, allora è quello della rete
        %migliore
        if (min(mse_matrix(iteratore_reti, :))>=mse_current)
            mse_minimo(iteratore_reti)=mse_current;
            % alcuni modelli sembra non volerli salvare perchè forse non
            % cadono nello standard network 
            nnetwork_array{iteratore_reti} = nnetwork;
            disp (['     salvata network num' num2str(iteratore_reti) ' in prossimità a val. minimo: ' num2str(mse_current)]);
            % per stampare dal array nnetwork_array basta fare  {1}
        end
    end
end



% calcolo media di ogni MSE ordinati in base a modello
mse_avg = [];
mse_avg = [mse_avg reti'];
mse_avg = [mse_avg string(mean(mse_matrix')') mse_minimo]
%matrice finale avrà: [nome_funzione_di_training, avg_mse, mse_minimo]

%% stampa di modello migliore

carico_test=load(1:end,3);
carico_test=normalize(carico_test)';
giorni_anno_test = load(1:end,2);
x_test=(1:length(carico_test))';
in_test=[x_test,giorni_anno_test]';

% per trovare riga con mse minimo
riga_mse_minimo=find (mse_minimo == min(mse_minimo));
simualzione=sim(nnetwork_array{riga_mse_minimo}, in_test);
figure(1);
title('modello migliore');
grid on;
hold on;
plot(simulazione);
hold on;
plot(carico_test);
legend('simulazione','dati');

%% stampa di errore relativo

figure(2);
errortraining= simulazione-carico_n;
plot (errortraining, 'black');
title('errore modello migliore');
legend('error training','error test');

%% stampa di modello peggiore
% per trovare riga con mse minimo
riga_mse_massimo=find (mse_minimo == max(mse_minimo));
simulazione1=sim(nnetwork_array{riga_mse_massimo}, in_test);
figure(3);
title('modello peggiore');
grid on;
hold on;
plot(simulazione1);
hold on;
plot(carico_test);
legend('simulazione','dati');

%% stampa di errore relativo

figure(4);
errortraining= simulazione1-carico_n;
plot (errortraining, 'black');
title('errore modello peggiore');
legend('error training','error test');




%% da qui in poi calcolo di un modello qualunque secondo la funzione di training di default
%{
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
%}

