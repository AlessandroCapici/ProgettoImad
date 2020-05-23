function [thetaLS,var_theta,SSR] = stimaLS(Y,phi)

thetaLS = phi\Y;
[n,q]=size(phi);
epsilon = Y - phi*thetaLS;
SSR = epsilon.' * epsilon;
sigma_hat = SSR/(n-q);
var_theta = sigma_hat * inv(phi.'*phi);

end
