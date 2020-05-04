function [thetaLS,var_theta,SSR] = stimaLS(Y,phi)
%thetaLS = inv(phi.'*phi)*(phi.'*Y);
thetaLS = phi\Y;    %questo risolve automaticamente il problema dei minimi quadrati in modo ottimizzato

[n,q]=size(phi);
epsilon = Y - phi*thetaLS;
SSR = epsilon.' * epsilon;
sigma_hat = SSR/(n-q);
var_theta = sigma_hat * inv(phi.'*phi);

end

