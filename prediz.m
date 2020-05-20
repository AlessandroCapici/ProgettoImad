function s_hat = prediz(d,w)
%PREDIZ Fa la previsione a lungo termine del consumo energetico della
%Germania. d e' il numero del giorno dell'anno considerato, w e' il giorno
%della settimana
%   Detailed explanation goes here

load('parametri_modello_annuale.mat')
load('parametri_modello_vacanzeNatale.mat')
if d<7 || d>356
    if d>356 
        x=d-356;
    else
        x=d+10;
    end    
    
    Phi=[1 x x.^2];
    supermegastima=Phi*thetaLS_vacanze;
    % Usiamo modello delle vacanze
else
      % ci servono thetaLS_y thetaLS_w sd media  
        
        
      % modello annuale
      Phi_y = [1 d d.^2 d.^3];  % Phi dell'anno
      stima_y = Phi_y*thetaLS_y;
      Phi_w = [cos(2*pi*w/7) sin(2*pi*w/7)...
        cos(2*pi*w*2/7) sin(2*pi*w*2/7)...
        cos(2*pi*w*3/7) sin(2*pi*w*3/7)];
      stima_w = Phi_w*thetaLS_w;
      
      supermegastima = stima_w + stima_y;
      
      
      
end
 s_hat = supermegastima*sd;
 s_hat = s_hat + media;       
 
end

