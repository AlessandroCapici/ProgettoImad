%% per non fare casino
clear;
clc;
close all;
warning('off','all');

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

%% variabili per learning
giorni_anno = load(1:end,2);
carico = load(1:end,3);
x= (1:364);
x= [x 1:364];
x=x';
carico_n = normalize(carico)';
n = length(carico);
in=[x , giorni_anno]';
in(1,:)=[1:364 1:364];
in(3,1:364)=0.1;
in(3,365:end)=0.2;


%% N = numero di iterazioni per set di parametri; param_max = max nodi (minore = più veloce)
N=3;
param_min=5;
param_max=20;
mse_current =[];
contatore =1;
mse_matrix =zeros(param_max^3, 4); %conterrà param_max^3 entries [param1 param2 param3 mse_avg]
for param_1 = param_min:param_max
    for param_2 = param_min:param_max
        for param_3 = param_min:param_max
            for iterazione = 1:N
                nnetwork=fitnet([param_1,param_2,param_3], 'trainbr' ); %devo coppiare questo valore altrimenti nnetwork non cambia
                nnetwork=train(nnetwork,in,carico_n); 
                simulazione=sim(nnetwork,in);
                mse_current=[mse_current mse(nnetwork, carico_n, simulazione, 5)]; 
            end
            fprintf("%i : %i.\t\t param: [%i, %i, %i]\t mse_avg = %f\n", contatore, (param_max-param_min)^3, param_1, param_2, param_3, mean(mse_current));
            mse_matrix (contatore, :) = [param_1 param_2 param_3 mean(mse_current)];
            contatore = contatore +1;
            mse_current=[];
        end
    end
end

fprintf("miglior rete con param: [%i %i %i]\t mse_avg: %f\n", mse_matrix((find(mse_matrix(:,4) == min(mse_matrix(:,4)))), :));


