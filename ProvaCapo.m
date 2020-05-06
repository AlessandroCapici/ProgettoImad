%% per non fare casino
clear;
clc;
close all;
%% caricamento dati
load('caricoDEday');
load = table2array(caricoDEday);
%% variabili a caso
giorni_anno = load(:,1);
carico = load(:,3);
x= (1:length(carico))';
carico_n = normalize(carico);
n = length(carico);

%%  plot dei dati
figure(1);
plot(x,carico_n,'o-');
grid on;
hold on;

%% ls model 
q=5;
Phi=ones(n,q);
thetaLS=Phi\carico_n;
carico_hat=Phi*thetaLS;
epsilon= carico-carico_hat;                 %MI DA TUTTO NaN MADONNA MAIALA.......non so il perchè
SSR=epsilon'*epsilon;
var_hat= SSR/(n-q);
var_thetaLS=var_hat*(inv(Phi'*Phi));
std_thetaLS=sqrt(var_thetaLS);
plot(x,carico_hat);
legend('dati','stima');
