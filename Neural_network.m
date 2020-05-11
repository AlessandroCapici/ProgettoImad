clear
close all
clc

%% Caricamento load
load('caricoDEday.mat')
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

% Stimo i load mancanti
for i = emptyRows
    load(i,3)= (load(i-7,3)+load(i+7,3))/2;
end
%% eliminazione trend
mean_year1 = mean(load(1:365,3));
mean_year2 = mean(load(366:end,3));

vec=[mean_year1*ones(365,1); mean_year2*ones(365,1)];

load1=load;
load1(:,3) = load1(:,3)-vec;
plot(load1(:,3),'-o');
%% variabili a caso
giorni_anno = load1(1:end,2);
carico = load1(1:end,3);
x= (1:length(carico))';
carico_n = normalize(carico)';
n = length(carico);
in=[x , giorni_anno]';
%% Creo la rete neurale

nnetwork=fitnet([20,20]);
...Size of the hidden layers in the network, specified as a row vector. 
...The length of the vector determines the number of hidden layers in the network.
...Example: For example, you can specify a network with 3 hidden layers, 
...where the first hidden layer size is 10, the second is 8, and the third is 5 as follows: [10,8,5]
...The input and output sizes are set to zero. The software adjusts the sizes of these during training according to the training data.

%% Setto alcuni parametri
nnetwork.trainParam.show=50;
nnetwork.trainParam.lr=0.10;    %li ho copiati da internet ahahha
nnetwork.trainParam.epochs=700;

%% Fase di learning
in_t=in(1:2,1:365);
copy_C=carico_n(1,1:365);
nnetwork=train(nnetwork,in_t,copy_C); 
simulazione=sim(nnetwork,in_t);
figure(1);
plot(simulazione);
grid on;
hold on;
plot(copy_C);
hold on;
legend('simulazione','load');
%% Fase di test
carico_test=load1(1:end,3);
carico_test=normalize(carico_test)';
giorni_anno_test = load1(1:end,2);
x_test=(1:length(carico_test))';
in_test=[x_test,giorni_anno_test]';
simtest=sim(nnetwork,in_test);

figure(2);
grid on;
hold on;
plot(simtest);
hold on;
plot(carico_test);
legend('simulazione','load');



