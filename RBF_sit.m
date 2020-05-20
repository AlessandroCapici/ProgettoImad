clear
close all
clc
warning('off','all')

%% Caricamento dati
load('caricoDEday.mat')
dati = table2array(caricoDEday);
x_vec = (1:size(dati,1))';
dati =  [dati x_vec];

%% Eliminazione dei NaN;
% NaN diventa valore medio tra dato della settimana precedente e successiva 
emptyRows=[];
for i=dati(:,4)'
    if isnan(dati(i,3))
        emptyRows=[emptyRows i];
    end
end

for i = emptyRows
    dati(i,3)= (dati(i-7,3)+dati(i+7,3))/2;
end

%% Stima del trend lineare e mostro modello senza trend.

Phi = [ones(size(dati,1),1) dati(:,4)];
thetaLS = Phi\dati(:,3);
trend = Phi*thetaLS;
dati_detrend = dati;
dati_detrend(:,3)-trend;
figure(1)
plot(dati(:,3))
hold on
plot(trend)
grid on
legend("dati", "trend");

figure(2)
plot(dati(:,3)-trend)
grid on
title("dati normalizzati");


%% Trend come media annuale


mean_year1 = mean(dati(1:365,3));
mean_year2 = mean(dati(366:end,3));

vec=[mean_year1*ones(365,1); mean_year2*ones(365,1)];

dati1=dati;
dati1(:,3) = dati1(:,3)-vec;

figure(3)
plot(dati1(:,3))
grid on

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
giorni_anno = dati1(1:end,2);
carico = dati1(1:end,3);

x= (1:365);
x= [x 1:365];
x=x';
%carico_n = normalize(carico)';
%%%%%%%%%
carico_n=carico';
n = length(carico);
in=[x , giorni_anno]';

%% Creo la rete neurale
nnetwork=fitnet([10,8,5]);
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
reti = {'trainlm', 'trainbfg', 'trainrp', 'trainscg', 'traincgb', 'traincgf', 'traincgp', 'trainoss', 'traingdx', 'traingdm', 'traingd', 'trainbr'};
% devo fare loop N volte per trovare array MSE di ciascun tipo di funzione

%%%% N SPECIFICA NUMERO DI ITERAZIONI. N BASSO FA BENE ALLA SALUTE DEL PC
N=2; %non impostarlo a 1. non gli piace
%%%% 

% variabili di servizio
lunghezza_iterazione=50/N;
lunghezza_iterazione=int16(lunghezza_iterazione);
%creo mse minimo e massimo per poter tenere conto di risultati estremi
mse_minimo=zeros(12,1);
%creo array di network per poter tenere conto di network migliore
nnetwork_array = cell(12,1);
% mse_matrix terr� valori mse calcolati per ogni tipo di funzione
mse_matrix (1:length(reti), 1:N)=1000000000;
for iteratore_reti = 1:length(reti)
    if(iteratore_reti==1)
        fprintf('\t\t\t');
        fprintf('---------------------progress---------------------');
        fprintf("\tavg\t\tmin");
    end
    fprintf('\n');
    fprintf("%s \t",reti{iteratore_reti});
    %disp (['funzione: ' reti{iteratore_reti} '  ' num2str(iteratore_reti) ' : ' num2str(length(reti))]);
    for c = 1:N
        %disp (['    iterazione: ' num2str(c) ' : ' num2str(N)]);
        %% Fase di learning
        nnetwork=fitnet([5,5,5], char(reti(iteratore_reti))); %devo coppiare questo valore altrimenti nnetwork non cambia
        nnetwork=train(nnetwork,in,carico_n); 
        simulazione=sim(nnetwork,in);
        %% fase di calcolo MSE
        mse_current=mse(nnetwork, carico_n, simulazione, 5);
        mse_matrix (iteratore_reti, c) = mse_current;
        %se mse corrente � il minimo nell'array, allora � quello della rete
        %migliore
        if (min(mse_matrix(iteratore_reti, :))>=mse_current)
            mse_minimo(iteratore_reti)=mse_current;
            % alcuni modelli sembra non volerli salvare perch� forse non
            % cadono nello standard network 
            nnetwork_array{iteratore_reti} = nnetwork;
            %disp (['        salvata network num ' num2str(iteratore_reti) ' in prossimit� a MSE minimo: ' num2str(mse_current)]);
            % per stampare dal array nnetwork_array basta fare  {1}
        end
        %% parte per visualizzazione
        for contatore_visualizzazione = 1:lunghezza_iterazione
            if(contatore_visualizzazione ==1 || (contatore_visualizzazione ==lunghezza_iterazione && c==N))
                fprintf("|");
                continue;
            end;
            fprintf("x");
        end
        if(c == N)
            fprintf("\t%2.3f,\t%2.3f",mean(mse_matrix(iteratore_reti, :)) ,mse_minimo(iteratore_reti));
        end
    end
end


%%% MATRICE IN FORMATO STRINGA CHE RIPORTA QUANTO VISIBILE SU COMAND LINE
%matrice finale avr�: [nome_funzione_di_training, avg_mse, mse_minimo]
mse_avg = [];
mse_avg = [mse_avg reti'];
mse_avg = [mse_avg string(round(mean(mse_matrix')',3)) mean(mse_minimo,3)];

%stampa di modello migliore e peggiore con relativi valori
riga_mse_minimo=find (mse_minimo == min(mse_minimo));
riga_mse_massimo=find (mse_minimo == max(mse_minimo));
fprintf("\nmodello migliore:\t%s \t%s\t%s\n", mse_avg(riga_mse_minimo, :));
fprintf("modello peggiore:\t%s\t%s\t%s\n", mse_avg(riga_mse_massimo, :));



%%% network_array contiene network corrispondenti a mse minimo per ogni
%%% funzione di training. scrivere network_array{indice} per usarla.


%% stampa di modello migliore (mse minimo)
%% cose a caso 


carico_test=dati1(1:end,3);
%carico_test=normalize(carico_test)';
carico_test=(carico_test)';
giorni_anno_test = load(1:end,2);
%x_test=(1:length(carico_test))';
%in_test=[x_test,giorni_anno_test]';

in_test2 = zeros(2, 1095);
in_test2(1,:)=[in(1,:) 1:365];
in_test2(2,:)=[in(2,:) in(2,3:367)];


% per trovare riga con mse minimo
riga_mse_minimo=find (mse_minimo == min(mse_minimo));
simulazione=sim(nnetwork_array{12}, in_test2);
%{
%%%%%%%%%%
array =cell(10,1);
for i=1:12
    nnetwork=fitnet([10,10,10], 'trainbr');
    nnetwork=train(nnetwork,in,carico_n); 
    simulazione=sim(nnetwork, in_test2);
    array{i}=nnetwork;
    figure(i);
    grid on;
    hold on;
    subplot(2,1,1);
    title('modello migliore');
    plot(simulazione);
    hold on;
    plot(carico_test);
    legend('simulazione','dati');
    % stampa di errore relativo
    subplot(2,1,2);
    errortraining= simulazione(1:730)-carico_n;
    plot (errortraining, 'black');
    title('errore modello migliore');
    legend('error training','error test');
end
%}
%% plot dati con trend

trend_1095=[];
trend_1095=[trend' (trend(1:365)')+(trend(730)-trend(1))];
figure(6);
plot(trend_1095+simulazione);
hold on;
plot(carico_test+trend');
legend('simulazione', 'carico');
title("estensione di simulazione a 3 anni con aggiunta di trend");


%% stampa di modello peggiore (MSE massimo)
% per trovare riga con mse minimo
riga_mse_massimo=find (mse_minimo == max(mse_minimo));
simulazione1=sim(nnetwork_array{riga_mse_massimo}, in_test2);
figure(3);
title('modello peggiore');
grid on;
hold on;
subplot(2,1,1);
plot(simulazione1);
hold on;
plot(carico_test);
legend('simulazione','dati');
% stampa di errore relativo
errortraining= simulazione1(1:730)-carico_n;
subplot(2,1,2);
plot (errortraining, 'black');
title('errore modello peggiore');
legend('error training','error test');


%% stampa di tutti i modelli
figure(5);
for contatore= 1:length(reti)
    simulazione3=sim(nnetwork_array{contatore}, in_test2);
    subplot(2,6,contatore, 'align'); 
    plot(simulazione3);
    hold on;
    plot(carico_test);
    title(reti{contatore});
end



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

