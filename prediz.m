function s_hat = prediz(d,w)
%PREDIZ Fa la previsione a lungo termine del consumo energetico della
%Germania. d e' il numero del giorno dell'anno considerato, w e' il giorno
%della settimana
%   Detailed explanation goes here

load('parametri_modello_annuale.mat')

if d<7 | d>356
    % Usiamo modello delle vacanze
else if 0 %giorno di vacanza generico
    % modello vacanze altro
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
      s_hat = supermegastima*sd;
      s_hat = s_hat + media;
      
      
end
        

%s_hat = 0;
end

