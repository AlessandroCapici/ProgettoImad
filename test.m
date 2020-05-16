function [fpe,aic,mdl] = test(N,q,SSR)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fpe = SSR*(N+q)/(N-q);
aic = 2*q/N + log(SSR);
mdl = log(N)*q/N + log(SSR);

end

